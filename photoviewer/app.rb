require 'view'
require 'clr_ext/system-json'

module Photoviewer
  class App
    def initialize
      @view = View.new(self)
      @url = "http://api.flickr.com/services/rest"
      @options = {
        :method => "flickr.photos.search",
        :format => "json",
        :nojsoncallback => "1",
        :api_key => "6dba7971b2abf352b9dcd48a2e5a5921",
        :sort => "relevance",
        :per_page => "30"
      }
      document.submit_search.onclick{|s, e| 
        begin
          create_request document.keyword.value, 1 
        rescue => e
          window.alert e
        end
      }
    end

    def create_request(keyword, page)
      @view.loading_start

      @options[:tags] = keyword
      @options[:page] = page
      @url = make_url @url, @options

      request = System::Net::WebClient.new
      request.download_string_completed{|_,e| show_images e.result }
      request.download_string_async System::Uri.new(@url)
    end

    def show_images(response)
      @flickr = System::Json::JsonValue.parse response
      @view.show_images @flickr, @options[:tags], @options[:page]
      @view.loading_finish
    end

  private

    def make_url(url, options)
      first, separator = true, '?'
      options.each do |key, value|
        separator = "&" unless first
        url += "#{separator}#{key}=#{value}"
        first = false
      end
      url
    end
  end
end

$app = Photoviewer::App.new
