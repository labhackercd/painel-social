class BillsController < ApplicationController
  before_filter :set_format_to_json
  before_action :load_bills
  respond_to :json

  # GET /bills
  def index
    respond_with @bills
  end

  # GET /topics
  # GET /topics/0
  # GET /topics/some-topic
  # GET /topics/ordered/0
  def topics
    r = bills_grouped_by_topic.map do |slug, bills|
      {
        :id => bills.first["id-categoria"],
        :slug => slug,
        :title => bills.first["categoria"],
        :views => bills.map { |b| b["value"] }.inject(:+)
      }
    end

    # Sort by views, descending
    r.sort_by! { |b| -b[:views] }

    # Set the relative view percentage for each of the topics
    views_total = r.map { |b| b[:views] }.inject(:+)

    r.each do |b|
      b[:perc] = b[:views].fdiv(views_total)
    end

    # Get the requested topic (if any)
    if params[:topic]
      if params[:topic] =~ /^\d+$/
        r = r.map { |i| i if i[:id] == params[:topic].to_i }.compact.first
        r = r.map { |i| i if i[:slug] == params[:topic] }.compact.first
      end
    elsif params[:ordered_index]
      # XXX Hack for the Arduino display which shouldn't show "other topics"
      r = r.map { |i| i if i[:slug] != 'outros-temas' }.compact
      r = r[params[:ordered_index].to_i]
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
