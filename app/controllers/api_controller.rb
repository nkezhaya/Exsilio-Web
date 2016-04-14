class ApiController < ApplicationController
  def index
    render json: { status: "OK" }
  end
end
