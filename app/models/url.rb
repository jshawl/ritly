class Url < ActiveRecord::Base

  before_save :make_directory, :save_html
  belongs_to :user

  def save_html
    doc = get_doc
    doc.css("[rel='stylesheet']").each {|node| node.remove}
  
    link = Nokogiri::XML::Node.new "link", doc 
  
    link['rel'] = 'stylesheet' 
    link['href'] = '/' + get_css
    link['type'] = 'text/css'
    doc.at_css('head') << link

    File.open( build_path( checksum( doc.to_html) , 'html' ), 'w') { |f| f.write(doc.to_html) }
    self.html_path = "#{URI( self.link ).host}/#{checksum( doc.to_html)}.html"
  end

  def get_css
    timestamp = Time.now.to_i.to_s
    file = File.open( build_path( timestamp, 'css' ) ,'w') do | f |
      get_css_tags.each do | c |
        contents = open(c).read
        str = contents.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
        f.write( str )
      end
    end

    hash = checksum(File.read( build_path( timestamp, 'css' ) ))
    FileUtils.mv(build_path( timestamp, 'css' ), build_path( hash, 'css' ))
    self.css = "#{URI( self.link ).host}/#{hash}.css"
  end

  private 

  def get_doc
    Nokogiri::HTML(open( self.link ))
  end

  def checksum string
    Digest::MD5.hexdigest string
  end

  def build_path(identifier = nil, file_type = nil)
    path = "public/#{URI(self.link).host}"
    path += "/#{identifier}.#{file_type}" if identifier
    path
  end

  def get_css_tags
    Nokogiri::HTML(open( self.link )).css('[rel="stylesheet"]').map do |l| 
      URI.join( link, l['href'] ).to_s 
    end
  end

  def make_directory
    FileUtils.mkdir_p( build_path ) unless Dir.exist?( build_path )
  end
end
