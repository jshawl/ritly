class UrlsController < ApplicationController

  before_action :authenticate_user!, :except => [:redirectors, :preview]

  def index
    @url = Url.new
    @urls = Url.where( user_id: current_user.id )
    @client = get_dropbox_client
    unless @client
	auth_start
    end
  end

  def upload
        client = get_dropbox_client
        unless client
	    auth_start
        end

        begin
            # Upload the POST'd file to Dropbox, keeping the same name
            resp = client.put_file(params[:file].original_filename, params[:file].read)
	    puts resp.inspect
            render :text => "Upload successful.  File now at #{resp['path']}"
        rescue DropboxAuthError => e
            session.delete(:access_token)  # An auth error means the access token is probably bad
            logger.info "Dropbox auth error: #{e}"
            render :text => "Dropbox auth error"
        rescue DropboxError => e
            logger.info "Dropbox API error: #{e}"
            render :text => "Dropbox API error"
        end
    end



  def get_dropbox_client
        if session[:access_token]
            begin
                access_token = session[:access_token]
                DropboxClient.new(access_token)
            rescue
                # Maybe something's wrong with the access token?
                session.delete(:access_token)
                raise
            end
        end
    end

    def get_web_auth()
        redirect_uri = 'http://localhost:3000/callback'
        DropboxOAuth2Flow.new(ENV['DB_APP_KEY'], ENV['DB_APP_SECRET'], redirect_uri, session, :dropbox_auth_csrf_token)
    end

    def auth_start
        authorize_url = get_web_auth().start()

        # Send the user to the Dropbox website so they can authorize our app.  After the user
        # authorizes our app, Dropbox will redirect them here with a 'code' parameter.
        redirect_to authorize_url
    end

    def auth_finish
        begin
            access_token, user_id, url_state = get_web_auth.finish(params)
            session[:access_token] = access_token
            redirect_to root_url
        rescue DropboxOAuth2Flow::BadRequestError => e
            render :text => "Error in OAuth 2 flow: Bad request: #{e}"
        rescue DropboxOAuth2Flow::BadStateError => e
            logger.info("Error in OAuth 2 flow: No CSRF token in session: #{e}")
            redirect_to(:action => 'auth_start')
        rescue DropboxOAuth2Flow::CsrfError => e
            logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
            render :text => "CSRF error"
        rescue DropboxOAuth2Flow::NotApprovedError => e
            render :text => "Not approved?  Why not, bro?"
        rescue DropboxOAuth2Flow::ProviderError => e
            logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
            render :text => "Strange error."
        rescue DropboxError => e
            logger.info "Error getting OAuth 2 access token: #{e}"
            render :text => "Error communicating with Dropbox servers."
        end
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
