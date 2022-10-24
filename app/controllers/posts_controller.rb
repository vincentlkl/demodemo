class PostsController < ApplicationController
  before_action :set_provider, only: :index
  def index
  end

  def show
    @post = Post.find(params[:id])
    @provider = @post.provider
  end

  private
  def set_provider
    params[:provider] = 'says' if params[:provider].blank?
    @provider = params[:provider]
    @posts = Post.send(params[:provider]).includes(:category).filtered({ category: params[:category] }).ordered
    @categories = Category.where(id: Post.send(params[:provider]).pluck(:category_id).uniq).ordered
  end
end
