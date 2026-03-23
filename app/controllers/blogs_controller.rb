# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_blog, only: %i[show edit update destroy]
  before_action :is_matching_login_user, only: %i[edit update destroy]
  before_action :is_secret_blog, only: [:show]

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

  def is_matching_login_user
    return if @blog.user == current_user
    redirect_to blogs_path, alert: "編集権限がありません"
  end

  def is_secret_blog
    if @blog.secret?
      return if @blog.user == current_user
      redirect_to blogs_path, alert: "権限がありません"
    end
  end

  def is_premium_user
    if current_user.premium === false && random_eyecatch === 1
      render
    end
  end
end
