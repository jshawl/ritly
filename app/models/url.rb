class Url < ActiveRecord::Base

  before_save :fetch

  def fetch
    @link = self.link
    @hostname = URI( @link ).host
    @path = 'public/'+ @hostname
    @now = Time.now.to_i.to_s
    @doc = Nokogiri::HTML(open( @link ))
    @html = save_html
    @css = get_css
  end

  def save_html
    Dir.mkdir( @path ) unless Dir.exist?( @path )
    @doc.css("[rel='stylesheet']").each do |node|
      node.remove
    end
    @html_path = @path+'/'+ Digest::MD5.hexdigest( @doc.to_html)+'.html'
    File.open(@html_path, 'w') { |f| f.write(@doc.to_html) }
    self.html_path = @hostname +  '/'+Digest::MD5.hexdigest( @doc.to_html)+'.html'
  end

  def get_css
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
