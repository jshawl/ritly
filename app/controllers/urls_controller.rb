class UrlsController < ApplicationController

  before_action :authenticate_user!, :except => [:redirectors, :preview]

  def index
    @url = Url.new
    @urls = current_user.urls
  end

  def create
    @url = Url.new( url_params )
    hashed = Digest::SHA1.hexdigest @url.link 
    @url.user_id = current_user.id
    @url.hashed = hashed[0..3]
    @url.save
    redirect_to urls_path
  end

  def show
    @url = Url.find( params[:id] )
  end

  def preview
    @url = Url.find_by_hashed( params[:code] )
    @path = @url.html_path.split('/').drop(1).join('/')
    @last_updated = @url.updated_at.strftime('%b %d, %Y')
  end

  def redirectors
    @url = Url.find_by_hashed( params[:code] )
  end

  def destroy
    @url = Url.find( params[:id] )
    @url.destroy 
    redirect_to urls_path
  end

  private

  def url_params
    params.require( :url ).permit( :link )
  end

end
