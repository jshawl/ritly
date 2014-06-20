class Url < ActiveRecord::Base

  before_save :get_css

  def get_css
    hostname = URI( self.link ).host
    Dir.mkdir('public/'+hostname) unless Dir.exist?( 'public/'+hostname )
    link = self.link
    now = Time.now.to_i.to_s
    @doc = Nokogiri::HTML(open( link ))
    @css_tags = @doc.css('[rel="stylesheet"]').map { |l| URI.join( link, l['href'] ).to_s }
    # open temp file for writing
    file = File.open( 'public/'+hostname+'/'+now + '.css','w') { | f |
      @css_tags.each do | c |
	contents = open(c).read
	f.write( contents )
      end
    }
    hash = Digest::MD5.hexdigest(File.read('public/'+hostname+'/'+now+'.css'))
    p hash
    File.rename('public/'+hostname+'/'+now+'.css', 'public/'+hostname+'/'+hash+".css")
    self.css = hostname+'/'+hash+".css"
  end
end
