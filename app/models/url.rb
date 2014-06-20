class Url < ActiveRecord::Base
  before_save :get_css
  def get_css
    link = self.link
    now = Time.now.to_i.to_s
    @doc = Nokogiri::HTML(open( link ))
    @css_tags = @doc.css('[rel="stylesheet"]').map { |l| URI.join( link, l['href'] ).to_s }
    # open temp file for writing
    file = File.open( now + '.css','w') { | f |
      @css_tags.each do | c |
	contents = open(c).read
	f.write( contents )
      end
    }
    hash = Digest::MD5.hexdigest(File.read(now+'.css'))
    p hash
    File.rename(now+'.css', hash+".css")
    self.css = hash+".css"
  end
end
