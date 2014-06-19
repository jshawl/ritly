class UrlsController < ApplicationController

  before_action :authenticate_user!, :except => [:redirectors, :preview]

  def index
    p user_signed_in?
    @url = Url.new
    @urls = Url.all
  end

  def create
    @url = Url.new( url_params )
    hashed = Digest::SHA1.hexdigest @url.link 
    @url.hashed = hashed[0..3]
    @url.save
    p fetch @url.link
    redirect_to urls_path
  end

  def fetch( link )
    `cd public && wget -E -H -k -K -p #{link}`
  end

  def show
    @url = Url.find( params[:id] )
  end

  def preview
    @url = Url.find_by_hashed( params[:code] )
    @path = @url.link.sub('https://','').sub('http://','')
  end

  def redirectors
    @url = Url.find_by_hashed( params[:code] )
    redirect_to @url.link
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
