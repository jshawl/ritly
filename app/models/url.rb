class Url < ActiveRecord::Base

  belongs_to :user
  before_save :fetch

  def fetch
    @link = self.link
    @hostname = URI( @link ).host
    @path = 'public/'+ @hostname
    @now = Time.now.to_i.to_s
    @doc = Nokogiri::HTML(open( @link ))

    Dir.mkdir( @path ) unless Dir.exist?( @path )

    @css = get_css
    @html = save_html
  end

  def checksum string
    Digest::MD5.hexdigest string
  end


  def save_html
    @doc.css("[rel='stylesheet']").each do |node|
      node.remove
    end
    link = Nokogiri::XML::Node.new "link", @doc 
    link['rel'] = 'stylesheet' 
    link['href'] = '/' + @css
    link['type'] = 'text/css' 
    @doc.at_css('head') << link

    @html_path = @path+'/'+ checksum( @doc.to_html)+'.html'
    File.open(@html_path, 'w') { |f| f.write(@doc.to_html) }
    self.html_path = @hostname +  '/'+checksum( @doc.to_html)+'.html'
  end

  def get_css
    @css_tags = @doc.css('[rel="stylesheet"]').map { |l| URI.join( @link, l['href'] ).to_s }
    file = File.open( @path +'/'+ @now + '.css','w') { | f |
      @css_tags.each do | c |
	contents = open(c).read
	str = contents.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
	f.write( str )
      end
    }
    hash = checksum(File.read(@path+'/'+@now+'.css'))
    @css_path = @path+'/'+ hash + '.css'
    FileUtils.mv(@path+'/'+@now+'.css', @css_path)
    self.css = @hostname +  '/'+hash+'.css'
  end
end
