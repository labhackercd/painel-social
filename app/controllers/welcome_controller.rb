class WelcomeController < ActionController::Base
  def index
    # XXX FIXME please, use the routing helpers here, because I can't
    redirect_to '/dashing/dashboards'
  end
end
