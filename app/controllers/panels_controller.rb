require Rails.root + 'app/jobs/twitter_job'

class PanelsController < ApplicationController
  before_action :set_panel, only: [:show, :edit, :update, :destroy]
  before_filter :find_panel, only: [:show, :update, :destroy]

  # GET /panels
  # GET /panels.json
  def index
    redirect_to '/'
  end

  # GET /panels/1
  # GET /panels/1.json
  def show
    render :layout => Dashing.config.dashboard_layout_path
  end

  # GET /panels/new
  def new
    @panel = Panel.new
  end

  # GET /panels/1/edit
  def edit
  end

  # POST /panels
  # POST /panels.json
  def create
    @panel = Panel.new(panel_params)

    # Enqueue a processing for the newly created panel.
    Resque.enqueue(TwitterProcess, @panel.slug, @panel.query)

    respond_to do |format|
      if @panel.save
        format.html { redirect_to @panel, notice: 'Painel criado com sucesso!' }
        format.json { render :show, status: :created, location: @panel }
      else
        format.html { render :new }
        format.json { render json: @panel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /panels/1
  # PATCH/PUT /panels/1.json
  def update

    clear_panel_on_clients

    updated = @panel.update(panel_params)

    # Enqueue a processing for the updated panel.
    Resque.enqueue(TwitterProcess, @panel.slug, @panel.query)

    respond_to do |format|
      if updated
        format.html { redirect_to @panel, notice: 'Panel was successfully updated.' }
        format.json { render :show, status: :ok, location: @panel }
        format.json { render json: @panel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /panels/1
  # DELETE /panels/1.json
  def destroy

    clear_panel_on_clients

    flush_panel_data

    @panel.destroy

    respond_to do |format|
      format.html { redirect_to panels_url, notice: 'Panel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_panel
      @panel = Panel.friendly.find(params[:id])
    end

    def find_panel
      if request.path != panel_path(@panel)
        return redirect_to @panel, :status => :moved_permanently
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def panel_params
      params.require(:panel).permit(:name, :slug, :query)
    end

    # TODO FIXME These probably belong to the model layer.

    def clear_panel_on_clients
      # FIXME TODO Damn, this is so hacky. We should have a canonical way to
      # notify clients that a widget should be updated. Really.
      # FIXME TODO Also, this should probably be in the model.
      # FIXME TODO Also, we should dequeue anything related to this panel that
      # may be being processed right now.
      Dashing.send_event(panel_mentions_event_id, {:comments => nil, :moreinfo => nil}, :cache => true)
      Dashing.send_event(panel_wordcloud_event_id, {:value => nil, :moreinfo => nil}, :cache => true)
    end

    def flush_panel_data
      # FIXME TODO This should probably be in the model.
      Dashing.redis.del(
        "#{Dashing.config.redis_namespace}:#{panel_mentions_event_id}",
        "#{Dashing.config.redis_namespace}:#{panel_wordcloud_event_id}"
      )
    end

    def panel_mentions_event_id
      "#{@panel.slug}_twitter_mentions"
    end

    def panel_wordcloud_event_id
      "#{@panel.slug}_twitter_wordcloud"
    end
end
