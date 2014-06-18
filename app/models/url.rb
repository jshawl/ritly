class Url < ActiveRecord::Base
  def initializer( url_params )
    hashed = Digest::SHA1.hexdigest @url.link 
    @url.hashed = hashed[0..3]
  end
end
