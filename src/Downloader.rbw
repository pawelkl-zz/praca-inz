#!/usr/bin/env ruby
require 'rubygems'
require 'curb'
require 'yaml'
require 'json'
require 'digest/md5'
# load 'moviehasher.rb'
load 'c:\dropbox\#code\praca-inz\src\moviehasher.rb'

require 'wx'
include Wx

require 'optparse'
require 'pp'

STDOUT.sync = true; exit_requested = false; Kernel.trap( "INT" ) { exit_requested = true }

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: curb.rbw [options] url1 url2 ..."

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end

  options[:url] = []
    opts.on( '-u', '--url a,b,c', Array, "List of urls" ) do|u|
    options[:url] = u
  end

  options[:cookie] = ""
    opts.on( '-c', '--cookie COOKIE', "" ) do|c|
    options[:cookie] = c
  end

  options[:cred] = ""
    opts.on( '-t', '--cred USER:PASSWORD', "" ) do|c|
    options[:cred] = c
  end

  options[:ref] = ""
    opts.on( '-r', '--ref REF-LINK', "" ) do|c|
    options[:ref] = c
  end

  options[:file] = ""
    opts.on( '-f', '--file FILE', "" ) do|c|
    options[:file] = c
  end

  options[:destination] = ""
    opts.on( '-d', '--destination DESTINATION-FOLDER', "" ) do|c|
    options[:destination] = c
  end
end

optparse.parse!

if __FILE__ == $0; pp "Options:", options; pp "ARGV:", ARGV end

=begin GUI
  class MinimalApp < App
     def on_init
      Frame.new(nil, -1, "Simple downloader",nil,Size.new(600,480)).show()
     end
  end

  class MyFrame < Frame
    def initialize()
      super(nil, -1, 'My Frame Title')
      @my_panel = Panel.new(self)
      @my_label = StaticText.new(@my_panel, -1, 'My Label Text', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_CENTER)
      @my_textbox = TextCtrl.new(@my_panel, -1, 'Default Textbox Value')
      @my_combo = ComboBox.new(@my_panel, -1, 'Default Combo Text',   DEFAULT_POSITION, DEFAULT_SIZE, ['Item 1', 'Item 2', 'Item 3'])
      @my_button = Button.new(@my_panel, -1, 'My Button Text')
    end
  end

  MinimalApp.new.main_loop

  exit!
=end

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

  def link_setup(cred,ref,cookie)
    # @c.username = user
    # @c.password = pass
    @c.userpwd = cred
    @c.autoreferer=true
    @c.connect_timeout=15
    @c.cookiefile = cookie
    # @c.cookiejar = cookiejar
    # @c.cookies=COOKIES # NAME=CONTENTS;
  end

  def parse_link_info(url)
    data, link, content, hash  =  {}, {}, {}, {}

    link["requested"] = url
    if @c.last_effective_url != url
      then link["final"] = @c.last_effective_url end

    link["requested-filename"] = @filename
    @final_filename = @c.last_effective_url.split(/\?/).first.split(/\//).last
    if @final_filename != @filename
      then link["final-filename"] = @final_filename end

    data["Link"] = link

    content["lenght"] = @c.downloaded_content_length
    content["type"] = @c.content_type
    data["Content"] = content

    data["filetime"] = Time.at(@c.file_time).utc.to_s

    @hash = MovieHasher::compute_hash(@save_location)
    @hash = MovieHasher::compute_hash(@save_location)

    if !@hash.nil?
      then hash["bigfile"] = @hash end

    @md5 = Digest::MD5.hexdigest(File.read(@save_location))
    hash["md5"] = @md5

    data["Hashes"] = hash

    @myjson = JSON.pretty_generate(data)
    print @myjson
  end

  def add_link(single_url,cred=nil,ref=nil,cookie=nil)
    link_setup(cred,ref,cookie)
    @c.url=single_url
    @filename = single_url.split(/\?/).first.split(/\//).last
    puts @filename
    @save_location = @target_dir + '\\' + (options[:file].nil? ? @filename : options[:file])
    @c.perform
    File.open(@save_location,"wb").write @c.body_str
    # if File.file?(@save_location)
      # then parse_additional_info @save_location end
    # puts "#{@save_location} #{@hash}"
    parse_link_info single_url
    File.open(@save_location + ":meta.json","w").write @myjson
  end

  def add_links(url_array,cred=nil,ref=nil,cookie=nil)
    link_setup(cred,ref,cookie)
    url_array.each do |single_url|
      @c.url=single_url
      @filename = single_url.split(/\?/).first.split(/\//).last
      @save_location = @target_dir + '\\' + @filename
      puts @save_location
      @c.perform
      File.open(@save_location,"wb").write @c.body_str
      # if File.file?(@save_location)
        # then parse_additional_info @save_location end
      # puts "#{@save_location} #{@hash}"
      parse_link_info single_url
      File.open(@save_location + ":meta.json","w").write @myjson
    end
  end
end

manager = Downloader.new options[:destination]
# manager.add_links(urls_to_download)

if ARGV.nil? 
  manager.add_link(options[:url])
else
  manager.add_links(ARGV)
end

=begin
  open('file.txt:stream1', 'w') do |f|
       f.puts('Your Text Here')
  end

  stream_text = open('file.txt:stream1').read
=end

sleep(3)