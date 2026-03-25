# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    secret_blog?
  end

  def new
    @blog = Blog.new
  end

  def edit
    matching_login_user?
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    matching_login_user?

    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    matching_login_user?
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    base = %i[title content secret]
    premium = current_user.premium? ? [:random_eyecatch] : []

    params.expect(blog: base + premium)
  end

  def matching_login_user?
    raise ActiveRecord::RecordNotFound if @blog.user != current_user
  end

  def secret_blog?
    raise ActiveRecord::RecordNotFound if @blog.secret? && @blog.user != current_user
  end
end
