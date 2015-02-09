require 'date'
require 'json'
require 'twitter'
require 'net/http'

class CausaBrasil

  def self.perform
    tema_counts = Hash.new({ value: 0 })
    
    # First get dates
    base_url = "http://www.causabrasil.com.br/apicausa/GetDateDelimiter"
    resp = Net::HTTP.get_response(URI.parse(base_url))
    data = resp.body
    
    result = JSON.parse(data)
    
    d = DateTime.strptime(result["DataHoraFinal"].split("/Date(").join("").split("000)/").join(""), "%s")
    
    # Now get tags
    # base_url = "http://www.causabrasil.com.br/apicausa/getTags"
    base_url = "http://www.causabrasil.com.br/apicausa/getTagsByDate?date="+d.day.to_s+"/"+d.month.to_s+"/"+d.year.to_s+"&hour="+d.hour.to_s
    
    resp = Net::HTTP.get_response(URI.parse(base_url))
    data = resp.body
    
    result = JSON.parse(data)
    
    count = 10
    result.each do |k|
      tooltip = "<span class=\"name\">Tema:</span> <span class=\"value\">"+k["Nome"]+"</span><br/>"
      tooltip += "<span class=\"name\">Quantidade de ocorrências:</span> <span class=\"value\">"+k["QtdOcorrencia"].to_s+"</span><br/>"
      hashtags = ""
      k["HashTag"].each do |hashtag|
        if hashtags.length > 0
          hashtags += ", "
        end
        hashtags += hashtag["Nome"]
      end
      tooltip += "<span class=\"name\">Hashtags:</span> <span class=\"value\">"+hashtags+"</span><br/>"      
      
      tema_counts[k["Nome"]] = {label: k["Nome"], value: k["QtdOcorrencia"], categoria: k["IdCategoria"], tooltip: tooltip}
      
      count -= 1
      
      # if count <= 0 then
      #   break
      # end
    end

    fill_colors = ['', '#92C05D', '#FF9F2E', '#DC5945', '#B77BD5', '#80B1D2']
    min_radius = 2
    max_radius = 120

    event = { items: tema_counts.values, fill_colors: fill_colors, min_radius: min_radius, max_radius: max_radius }
    Dashing.send_event('causabrasil', event, :cache => true)
  end
end
