require 'rubygems'
require 'curb'
# require 'addressable/uri'
# require 'net/http'
require 'yaml'
require 'json'
load 'moviehasher.rb'

# STDOUT.sync = true
# exit_requested = false
# Kernel.trap( "INT" ) { exit_requested = true }

urls_to_download = [
  'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
  # 'http://www.opensubtitles.org/addons/avi/breakdance.avi', # 8e245d9679d31e12
  # # 'http://www.opensubtitles.org/addons/avi/dummy.rar', # 61f7751fc2a72bfb
  'http://static.skynetblogs.be/media/163667/1714742799.2.jpg',
  # 'http://imgur.com/NMHpw.jpg',
  # 'http://i.imgur.com/USdtc.jpg',
  # 'http://i.imgur.com/Dexpm.jpg',
  # 'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
  # 'http://static3.blip.pl/user_generated/update_pictures/2639011.jpg',
  # 'http://3.asset.soup.io/asset/3187/8131_3a06.jpeg',
  # 'http://e.asset.soup.io/asset/3182/1470_9f47_500.jpeg',
  'http://static3.blip.pl/user_generated/update_pictures/2638909.jpg'
]

class Downloader
  def initialize(directory)
    @PASS=nil
    @COOKIE=nil
    @filename=nil
    @full_file_location = nil
    @myjson=nil
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

  def parse_link_info(link)
    data  =  {}

    data["requested-link"] = link
    if @c.last_effective_url != link
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

    if !@hash.nil?
      then data["hash"] = @hash end

    @myjson = JSON.pretty_generate(data)
    print @myjson
    puts
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
      @filename = single_url.split(/\?/).first.split(/\//).last
      puts @filename
      @save_location = @target_dir + '\\' + @filename
      @c.perform
      File.open(@save_location,"wb").write @c.body_str
      # if File.file?(@save_location)
        # then parse_additional_info @save_location end
      # @hash = MovieHasher::compute_hash(@save_location)
      # puts "#{@save_location} #{@hash}"
      # puts parse_additional_info(@save_location)
      # sleep(1000)
      # @hash = MovieHasher::compute_hash(@save_location)
      # puts "#{@save_location} #{@hash}"
      # @hash = MovieHasher::compute_hash(@save_location)
      # puts "#{@save_location} #{@hash}"
      parse_link_info single_url
      File.open(@save_location + ":meta.json","w").write @myjson
    end
  end

  # def parse_additional_info(filename)
  #   MovieHasher::compute_hash(@save_location)
  # end
end

manager = Downloader.new 'c:\temp'
manager.add_links(urls_to_download)

# open('file.txt:stream1', 'w') do |f|
#      f.puts('Your Text Here')
# end

# stream_text = open('file.txt:stream1').read