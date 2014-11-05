class WelcomeController < ApplicationController
  def index
    @panels = Panel.all
  end
end
