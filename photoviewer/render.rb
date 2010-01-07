require 'system-json.rb'
require 'erb'

class Render
  def initialize(flickr, tags, current_page)
    @flickr = flickr
    @tags = tags
    @current_page = current_page
  end

  def generate_photos
    if @flickr.stat == "ok" && @flickr.photos.total.to_i > 0
      erb :images
    else
      "No images found!"
    end
  end

  def generate_pages
    if @flickr.photos.total.to_i > 0
      @num_pages = @flickr.photos.pages > 15 ? 15 : @flickr.photos.pages.to_i
      erb :pages if @num_pages > 1
    end
  end

  def hook_page_events(div)
    $app.document.get_element_by_id(div.to_s.to_clr_string).children.each do |child|
      if child.id.to_s.to_i == @current_page
        child.css_class = "active" 
      else
        child.onclick { |s, args| $app.create(@tags, child.id.to_s.to_i) }
      end
    end
  end

private

  def erb(template, bind = nil)
    ERB.new(File.read("#{template}.erb")).result(bind || binding)
  end
end
