require Rails.root + 'app/jobs/twitter_job'

class PanelsController < ApplicationController
  before_action :set_panel, only: [:show, :edit, :update, :destroy]
  before_filter :find_panel, only: [:show, :update, :destroy]

  # GET /panels
  # GET /panels.json
  def index
    @panels = Panel.all
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

    respond_to do |format|
      if @panel.save
        format.html { redirect_to @panel, notice: 'Panel was successfully created.' }
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

    # limpar o evento do tal painel :)
    Dashing.send_event("#{@panel.slug}_twitter_mentions", {:comments => nil})
    Dashing.send_event("#{@panel.slug}_twitter_wordcloud", {:value => nil})

    updated = @panel.update(panel_params)

    # TODO dequeue anything that still unprocessed?
    Resque.enqueue(TwitterProcess, @panel.slug, @panel.query)

    respond_to do |format|
      if updated
        format.html { redirect_to @panel, notice: 'Panel was successfully updated.' }
        format.json { render :show, status: :ok, location: @panel }
      else
        format.html { render :edit }
        format.json { render json: @panel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /panels/1
  # DELETE /panels/1.json
  def destroy
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
end
