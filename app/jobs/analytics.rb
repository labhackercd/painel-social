require 'date'
require 'google/api_client'
require 'i18n'
require 'json'
require 'mechanize'
require 'net/http'
require 'nokogiri'

class ProjetosDeLei

  def self.perform
    secrets = Rails.application.secrets.google_analytics

    key_secret = secrets['key_secret']
    profile_id = secrets['profile_id']
    service_account_email = secrets['service_account_email']

    key_file = File.join(Rails.root, 'config', 'analytics', 'privatekey.p12')

    # Mechanize - used to parse pages
    agent = Mechanize.new

    # Google API Client
    client = Google::APIClient.new(
      :application_name => "Painel Camara",
      :application_version => "0.0.1"
    )

    # Load our credentials for the service account
    key = Google::APIClient::PKCS12.load_key(key_file, key_secret)
    asserter = Google::APIClient::JWTAsserter.new(
       service_account_email,
       'https://www.googleapis.com/auth/analytics.readonly',
       key)
    
    # Request a token for our service account
    client.authorization = asserter.authorize() 

    # Load Analytics client
    analytics = client.discovered_api('analytics','v3')

    ### Notícias mais lidas
    agenciacamara_counts = Hash.new({ value: 0 })
    
    startDate = DateTime.now.prev_day.prev_day.prev_day.strftime("%Y-%m-%d")
    endDate = DateTime.now.strftime("%Y-%m-%d")

    noticiasMaisLidas = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
      'ids' => "ga:" + profile_id,
      'dimensions' => 'ga:pagePath',
      'metrics' => "ga:pageviews",
      'filters' => "ga:pagePath=~^/camaranoticias/.*\\.html$",
      'sort' => "-ga:pageviews",
      'start-date' => startDate,
      'end-date' => endDate,
      'max-results' => "5" 
    })

    noticiasMaisLidas.data.rows.each do |r|
      link = "http://www2.camara.leg.br"+r[0]
      agent.get(link)
      title = agent.page.title.sub(" - Câmara Notícias - Portal da Câmara dos Deputados", "")
      pageviews = r[1]
      
      agenciacamara_counts[title] = {label: title, value: pageviews, link: link}
    end
    
    Dashing.send_event('noticiasagenciacamara', { items: agenciacamara_counts.values }, :cache => true)

    ### PLs mais visualizados
    pl_counts = Hash.new({ value: 0 })
    
    startDate = DateTime.now.prev_day.prev_day.prev_day.prev_day.prev_day.prev_day.prev_day.strftime("%Y-%m-%d")
    endDate = DateTime.now.strftime("%Y-%m-%d")

    plVisitCount = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
      'ids' => "ga:" + profile_id,
      'dimensions' => 'ga:pagePath',
      'metrics' => "ga:pageviews",
      'filters' => "ga:pagePath=~^/proposicoesWeb/fichadetramitacao\\?idProposicao=.*$",
      'sort' => "-ga:pageviews",
      'start-date' => startDate,
      'end-date' => endDate,
      'max-results' => "200" 
    })

    totalPLVisitCount = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
      'ids' => "ga:" + profile_id,
      'metrics' => "ga:pageviews",
      'filters' => "ga:pagePath=~^/proposicoesWeb/fichadetramitacao\\?idProposicao=.*$",
      'sort' => "-ga:pageviews",
      'start-date' => startDate,
      'end-date' => endDate,
    })

    totalPLVisitCount = totalPLVisitCount.data.rows[0][0].to_i

    tema_counts = Hash.new()
    
    i = 0
    plVisitCount.data.rows.each do |r|
      id = r[0].match('\=(.*)$')[1]
      
      obter_proposicao_url = 'http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ObterProposicaoPorID?IdProp=' + id
      
      xml_data = Net::HTTP.get_response(URI.parse(obter_proposicao_url)).body
      xml_doc = Nokogiri::XML(xml_data)
      
      nome_proposicao = xml_doc.xpath('/proposicao/nomeProposicao').text
      ementa = xml_doc.xpath('/proposicao/Ementa').text
      explicacao_ementa = xml_doc.xpath('/proposicao/ExplicacaoEmenta').text
      temas = xml_doc.xpath('/proposicao/tema').text
      temas_list = temas.split('; ')
      situacao = xml_doc.xpath('/proposicao/Situacao').text
      
      temas_list.each do |x|
        count = tema_counts.fetch(x, { count: 0 })[:count] += 1
        tema_counts[x] = { count: count }
      end
      
      pageviews = r[1].to_i
      
      tooltip = "<span class=\"name\">Proposição:</span> <span class=\"value\">"+nome_proposicao+"</span><br/>"
      if explicacao_ementa.length < 6
        tooltip += "<span class=\"name\">Ementa:</span> <span class=\"value\">"+ementa+"</span><br/>"      
      else
        tooltip += "<span class=\"name\">Explicacação da ementa:</span> <span class=\"value\">"+explicacao_ementa+"</span><br/>"      
      end
      tooltip += "<span class=\"name\">Temas:</span> <span class=\"value\">"+temas+"</span><br/>"      
      tooltip += "<span class=\"name\">Situação:</span> <span class=\"value\">"+situacao+"</span><br/>"      
      tooltip += "<span class=\"name\">Visualizações:</span> <span class=\"value\">"+pageviews.to_s+"</span><br/>"      
      
      pl_counts[id] = {label: nome_proposicao, value: pageviews, tooltip: tooltip, temas: temas_list}
      
      #$top_pls[i] = {:nomeProposicao => I18n.transliterate(nome_proposicao), :temas =>  I18n.transliterate(temas_list.join(", ")), :contador => pageviews / totalPLVisitCount.to_f }
      i += 1
    end
    
    # Ordenar decrescentemente por count de cada tema
    tema_counts = Hash[tema_counts.sort_by {|_key, value| -value[:count]}]
    
    labels = Array.new()
    
    fill_colors = ['#7fc97f', '#beaed4', '#fdc086', '#ffff99', '#386cb0',     '#999999']
    
    # Associar o ID a cada tema
    i = 0
    max_categories = 5
    tema_counts.each do |k, v|
      v[:id] = i
          
      # Popular lista de tema_labels
      if i < max_categories
        labels[i] = { :name => k, :color => fill_colors[i] }
        # labels[k] = i
      else
        labels[i] = { :name => "Outros temas", :color => fill_colors[i] }
        # labels["Outros temas"] = i
      end
      
      # Incrementar número apenas até certo número; depois agrupar todos no mesmo ID
      if i < max_categories
        i += 1
      end
      
    end
    
    # Associar cada um a uma categoria, dando preferência às maiores
    
    pl_counts.each do |k, v|
      max_count = 0
      max_id = nil
      v[:temas].each do |x|
        if tema_counts[x][:count] > max_count
          max_count = tema_counts[x][:count]
          max_id = tema_counts[x][:id]
        end
      end
      v[:categoria] = max_id
    end
    
    min_radius = 2
    max_radius = 60
    
    pls = {
      :items  => pl_counts.values,
      :labels => labels,
      :fill_colors  => fill_colors,
      :min_radius   => min_radius,
      :max_radius   => max_radius
    }
    Dashing.send_event('pls', pls, :cache => true)
  end
end

#Dashing.scheduler.every '6h', :first_in => 0.4 do
#  do_the_thing
#end
