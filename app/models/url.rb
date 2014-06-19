class Url < ActiveRecord::Base
  def initializer( url_params )

    hashed = Digest::SHA1.hexdigest @url.link 
    @url.hashed = hashed[0..3]

    path = @url.link.gsub("https?:\/\/", "")
    @url.path = path

  end
end
