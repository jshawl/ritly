class Url < ActiveRecord::Base

  before_save :fetch

  def fetch
    @link = self.link
    @hostname = URI( @link ).host
    @path = 'public/'+ @hostname
    @now = Time.now.to_i.to_s
    @doc = Nokogiri::HTML(open( @link ))
    @css = get_css
  end

  def get_css
    Dir.mkdir( @path ) unless Dir.exist?( @path )
    @css_tags = @doc.css('[rel="stylesheet"]').map { |l| URI.join( @link, l['href'] ).to_s }
    file = File.open( @path + @now + '.css','w') { | f |
      @css_tags.each do | c |
	contents = open(c).read
	f.write( contents )
      end
    }
    hash = Digest::MD5.hexdigest(File.read(@path+@now+'.css'))
    p hash
    File.rename(@path+@now+'.css', @path+hash+".css")
    self.css = @hostname+'/'+hash+".css"
    self.css
  end
end
