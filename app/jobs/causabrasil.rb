require 'date'
require 'json'
require 'twitter'
require 'net/http'

class CausaBrasil

  def self.perform
    tema_counts = Hash.new({ value: 0 })
    
    # First get dates
    base_url = "http://brasilcausal.labhackercd.net"

    uri = URI.parse(base_url)
    net = Net::HTTP.new(uri.host, uri.port)
    net.read_timeout = 1000 # XXX Stupidly high timeout because our API sucks.
    resp = net.request_get("/")

    data = resp.body
    
    result = JSON.parse(data)
    
    result['topics'].each do |k, v|
      tooltip = "<span class=\"name\">Tema:</span> <span class=\"value\">"+v["name"]+"</span><br/>"
      tooltip += "<span class=\"name\">Quantidade de ocorrências:</span> <span class=\"value\">"+v["count"].to_s+"</span><br/>"
      tooltip += "<span class=\"name\">Hashtags:</span> <span class=\"value\">"+v["search_terms"]+"</span><br/>"      
      
      tema_counts[v["name"]] = {label: v["name"], value: v["count"], categoria: 1, tooltip: tooltip}
    end

    fill_colors = ['', '#92C05D', '#FF9F2E', '#DC5945', '#B77BD5', '#80B1D2']
    min_radius = 2
    max_radius = 120

    event = { items: tema_counts.values, fill_colors: fill_colors, min_radius: min_radius, max_radius: max_radius }
    Dashing.send_event('causabrasil', event, :cache => true)
  end
end
