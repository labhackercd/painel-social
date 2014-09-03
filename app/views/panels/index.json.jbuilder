json.array!(@panels) do |panel|
  json.extract! panel, :id, :name, :slug, :query
  json.url panel_url(panel, format: :json)
end
