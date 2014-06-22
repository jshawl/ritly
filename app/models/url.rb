class Url < ActiveRecord::Base

  belongs_to :user
  before_save :fetch

  def fetch
    @link = self.link
    @hostname = URI( @link ).host
    @path = 'public/'+ @hostname
    @now = Time.now.to_i.to_s
    @doc = Nokogiri::HTML(open( @link ))

    make_directory

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
    link['href'] = '/' + get_css
    link['type'] = 'text/css' 
    @doc.at_css('head') << link

    @html_path = @path+'/'+ checksum( @doc.to_html)+'.html'
    File.open(@html_path, 'w') { |f| f.write(@doc.to_html) }
    self.html_path = @hostname +  '/'+checksum( @doc.to_html)+'.html'
  end

  def get_css
    css_tags = get_css_tags
    timestamp = Time.now.to_i.to_s
    file = File.open( build_path( timestamp ) ,'w') do | f |
      css_tags.each do | c |
        contents = open(c).read
        str = contents.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
        f.write( str )
      end
    end

    hash = checksum(File.read( build_path( timestamp ) ))
    FileUtils.mv(build_path( timestamp ), build_path( hash ))
    self.css = "#{URI( self.link ).host}/#{hash}.css"
  end

  def build_path(identifier = nil)
    path = "public/#{URI(self.link).host}"
    path += "/#{identifier}.css" if identifier
    path
  end

  def get_css_tags
    Nokogiri::HTML(open( link )).css('[rel="stylesheet"]').map do |l| 
      URI.join( link, l['href'] ).to_s 
    end
  end

  def make_directory
    Dir.mkdir( build_path ) unless Dir.exist?( build_path )
  end
end
