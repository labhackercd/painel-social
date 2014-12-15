class PanelsController < ApplicationController
  before_action :set_panel, :only => [:show]
  before_filter :find_panel, :only => [:show]

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

    # Never trust parameters from the scary internet, only allow the white
    # list through.
    def panel_params
      params.require(:panel).permit(:name, :slug, :query)
    end

    def panel_mentions_event_id
      "#{@panel.slug}_twitter_mentions"
    end

    def panel_wordcloud_event_id
      "#{@panel.slug}_twitter_wordcloud"
    end
end
