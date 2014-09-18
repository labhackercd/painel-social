class BillsController < ApplicationController
  before_filter :set_format_to_json
  before_action :load_bills
  respond_to :json

  # GET /bills
  def index
    respond_with @bills
  end

  # GET /topics
  # GET /topics/some-topic
  def topics
    r = bills_grouped_by_topic.map do |slug, bills|
      {
        :id => bills.first["id-categoria"],
        :slug => slug,
        :title => bills.first["categoria"],
        :views => bills.map { |b| b["value"] }.inject(:+)
      }
    end

    views_total = r.map { |b| b[:views] }.inject(:+)

    r.each do |b|
      b[:perc] = b[:views].fdiv(views_total)
    end

    if params[:topic]
      r = r.map { |i| i if i[:slug] == params[:topic] }.compact.first
    end

    respond_with r
  end

  private
    def set_format_to_json 
      request.format = 'json'
    end

    def load_bills
      @redis = Dashing.redis
      
      data = @redis.get("#{Dashing.config.redis_namespace}:pls")
      data = JSON.parse(data)

      @bills = data["items"]

      @bills.each do |bill|
        catid = bill["id-categoria"] = bill["categoria"]
        bill["categoria"] = data["labels"][catid]["name"]
      end

    ensure
      @redis.quit
    end

    def bills_grouped_by_topic
      @bills.group_by do |item|
        item["categoria"].parameterize
      end
    end
end
