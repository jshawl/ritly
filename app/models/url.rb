class Url < ActiveRecord::Base
  def initializer( url_params )
    p url_params.url.link
  end
end
