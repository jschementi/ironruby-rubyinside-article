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
      erb %Q{
        <div class='images'>
          <% @flickr.photos.photo.each do |p| %>
            <%= photo p %>
          <% end %>
        </div>
      }
    else
      "No images found!"
    end
  end

  def photo(p)
    erb %q{
      <% source = "http://farm#{p.farm.to_i}.static.flickr.com/#{p.server}/#{p.photo_id}_#{p.secret}" %>
      <div class='image'>
        <a href="<%= source %>.jpg"
           title="&lt;a href=&quot;http://www.flickr.com/photos/<%= p.owner %>/<%= p.photo_id %>&quot; target=&quot;_blank&quot;&gt;<%= p.title %>&lt;/a&gt;"
           rel="lightbox[<%= @tags %>]"
        >
          <img src="<%= source %>_s.jpg" />
        </a>
      </div>
    }, binding
  end

  def generate_pages
    if (@flickr.photos.total.to_i > 0 && 
        (num_pages = @flickr.photos.pages > 10 ? 10 : @flickr.photos.pages.to_i) > 1 &&
        num_pages > 1
    )
      erb %Q{
        <% num_pages.times do |i| %>
          <a href='javascript:void(0)' id='<%= i + 1 %>'><%= i + 1 %></a>
        <% end %>
      }, binding
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
    ERB.new(template).result(bind || binding)
  end

  def tag(name, options, &block)
    output = ""
    output << "<#{name}"
    keyvalue = options.collect { |key, value| "#{key}=\"#{value}\"" }
    output << " #{keyvalue.join(" ")}" if keyvalue.size > 0
    if block 
      output << ">"
      output << yield 
      output << "</#{name}>"
    else
      output << " />"
    end
    output
  end

end
