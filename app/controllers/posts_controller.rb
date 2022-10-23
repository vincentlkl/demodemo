class PostsController < ApplicationController
  before_action :set_kind
  def index
  end

  def show
  end

  private
  def set_kind
    @kind = params[:kind]
  end
end
