# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :matching_login_user?, only: %i[edit update destroy]
  before_action :secret_blog?, only: [:show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    if current_user.premium?
      params.expect(blog: %i[title content secret random_eyecatch])
    else
      params.expect(blog: %i[title content secret])
    end
  end

  def matching_login_user?
    return if @blog.user == current_user

    render file: Rails.root.join('public/404.html'), status: :not_found
  end

  def secret_blog?
    return unless @blog.secret?
    return if @blog.user == current_user

    render file: Rails.root.join('public/404.html'), status: :not_found
  end

  def premium_user?
    current_user.premium == false && random_eyecatch == 1
  end
end
