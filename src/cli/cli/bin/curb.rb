require 'rubygems'
require 'curb'
# require 'addressable/uri'
# require 'net/http'
require 'yaml'
require 'json'
load 'moviehasher.rb'

STDOUT.sync = true
exit_requested = false
Kernel.trap( "INT" ) { exit_requested = true }

urls_to_download = [
  'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
  'http://static.skynetblogs.be/media/163667/1714742799.2.jpg',
  'http://imgur.com/NMHpw.jpg',
  'http://i.imgur.com/USdtc.jpg',
  'http://i.imgur.com/Dexpm.jpg',
  'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
  'http://static3.blip.pl/user_generated/update_pictures/2639011.jpg',
  'http://3.asset.soup.io/asset/3187/8131_3a06.jpeg',
  'http://e.asset.soup.io/asset/3182/1470_9f47_500.jpeg'
]

class Attributes
  def initialize(link_url=nil,url=nil,filename=nil,contenttype=nil,content_lenght=nil)
    @link_url=link_url
    @url=url
    @filename=filename
    @contentype=contenttype
    @content_lenght=content_lenght
  end

  # def to_json

  # end
end

class Downloader
  def initialize(directory)
    @PASS=nil
    @COOKIE=nil
    @filename=nil
    @full_file_location = nil
    @target_dir = directory
    File.exists? @target_dir # File.directory? @target_dir
    @c = Curl::Easy.new
    curl_setup
  end

  def curl_setup
    @c.dns_cache_timeout = 8
    @c.fetch_file_time = true
    @c.verbose = false
    @c.follow_location = true
    @c.on_success {|easy| puts "success #{@filename}"}
    # @c.on_body{|data| responses[url] << data; data.size }
    @c.header_in_body = false
  end

  def link_setup(user,pass,ref,cookie)
    @c.username = user
    @c.password = pass
    # @c.userpwd = user:password
    @c.autoreferer=true
    @c.connect_timeout=15
    @c.cookiefile = cookie
    # @c.cookiejar = cookiejar
    # @c.cookies=COOKIES # NAME=CONTENTS;
  end

  def parse_link_info
    @contenttype = @c.content_type
    @filetime = @c.file_time
    # @dlspeed = @c.download_speed
    @content_length = @c.downloaded_content_length
  end

  def add_link(url,user=nil,pass=nil,ref=nil,cookie=nil)
    link_setup(user,pass,ref,cookie)
    parse_link_info
    @c.perform
    # puts @c.username
  end

  def add_links(url_array,user=nil,pass=nil,ref=nil,cookie=nil)
    link_setup(user,pass,ref,cookie)
    url_array.each do |single_url|
      @c.url=single_url
      parse_link_info
      # puts "#{single_url} - #{@filename} - length #{@content_length} - time #{@filetime}"
      @filename = single_url.split(/\?/).first.split(/\//).last
      puts @filename
      @save_location = @target_dir + '\\' + @filename

      # @destinationfile = File.new(@full_file_location,"w")
      # @c.on_body{|data|
      # File.open(@save_location,"w").write data
      # @destinationfile.write data
      # @save_location = @save_location + ":meta.txt"
      # # File.open(@target_dir + "header.txt","w").write "LOL"
      # # @c.header_str
      # # puts "Headers\n" + @c.headers.to_s
      # # puts "Body\n" + @c.body_str
      # # puts "URL\n" + @c.last_effective_url
      #    }
      #    # @c.on_header{|data|
      #    #   File.open(@save_location + ":header.txt","w").write data}

      @c.perform
      File.open(@save_location,"wb").write @c.body_str
      # File.open(@save_location + ":header.txt","w").write @c.header_str

      # File.open(@save_location + ":meta.yaml","w").write Attributes.new(single_url,@c.last_effective_url.to_s,@filename,@contenttype.to_s,@content_lenght.to_i).to_yaml(:UseBlock => true)

      # File.open(@save_location + ":meta.json","w").write JSON.fast_generate(Attributes.new(single_url,@c.last_effective_url.to_s,@filename,@contenttype.to_s,@content_lenght.to_i))

      data  =  {}

      data["requested-link"] = single_url
      if @c.last_effective_url != single_url 
        then data["final-link"] = @c.last_effective_url end

      data["requested-filename"] = @filename
      @final_filename = @c.last_effective_url.split(/\?/).first.split(/\//).last
      if @final_filename != @filename
        then data["final-filename"] = @final_filename end

      data["content-lenght"] = @c.downloaded_content_length
      data["content-type"] = @c.content_type
      data["filetime"] = Time.at(@c.file_time).utc.to_s
      # @dlspeed = @c.download_speed
      # print data

      myjson = JSON.pretty_generate(data)
      # print myjson
    end
  end
end

manager = Downloader.new 'c:\temp'

# manager.add_link("http://www.shapings.com/images/detailed/2/CVNESPT.jpg")
# manager.download(1)
# manager.add_link('http://www.yahoo.com/','http://www.cnn.com/')
# manager.download(2)
# manager.add_links(urls_to_download)
manager.add_links(urls_to_download)

# open('file.txt:stream1', 'w') do |f|
#      f.puts('Your Text Here')
# end

# stream_text = open('file.txt:stream1').read