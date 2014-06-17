class UrlsController < ApplicationController

  def index
    @url = Url.new
    @urls = Url.all
  end

  def create
    @url = Url.new( url_params )
    @url.hashed = Digest::SHA1.hexdigest @url.link 
    @url.save
    redirect_to @url
  end

  def show
    @url = Url.find( params[:id] )
  end

  def redirectors
    @url = Url.find_by( hashed:  params[:code] )
    redirect_to @url.link
  end

  private

  def url_params
    params.require( :url ).permit( :link )
  end

end
