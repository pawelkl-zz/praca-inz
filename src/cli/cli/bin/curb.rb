require 'rubygems'
require 'curb'
require 'addressable/uri'

# LinkQueue = Hash.new

# class Queue
# 	def initialize(maxconcurrent)
# 		@maxconcurrent = maxconcurrent
# 	end

# 	def add(url)

# 		filename = url.split(/\?/).first.split(/\//).last
# 	end

# 	# Curl::Easy.http_head(url) {|easy| }
# end

# thisQueue = Queue.new(5)
# thisQueue.add('http://www.shapings.com/images/detailed/2/CVNESPT.jpg')
# thisQueue.download

STDOUT.sync = true
exit_requested = false
Kernel.trap( "INT" ) { exit_requested = true }

urls_to_download = [
  'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
  'http://www.yahoo.com/',
  'http://www.cnn.com/',
  'http://www.espn.com/',
  'http://www.shapings.com/images/detailed/2/CVNESPT.jpg'
]

# path_to_files = [
#   'google.com.html',
#   'yahoo.com.html',
#   'cnn.com.html',
#   'espn.com.html'
# ]

# Curl::Multi.download(urls_to_download, {:follow_location => true}, {}, path_to_files) {|c,p|}

class QueueItem
	def initialize(url)
		@url = url
	end

	def url=(u)
		set :url, u
	end
end

class Downloader
	def initialize(directory)
		@PASS=nil
		@COOKIE=nil
		@filename=nil
		@c = Curl::Easy.new
		@target_dir = directory
		curl_setup
	end

	def curl_setup
		@c.dns_cache_timeout = 8
		@c.fetch_file_time = true
		@c.verbose = false
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
		contenttype = @c.content_type
		filetime = @c.file_time
		dlspeed = @c.download_speed
		content_length = @c.downloaded_content_length
	end

	def add_link(url,user=nil,pass=nil,ref=nil,cookie=nil)
		filename = url.split(/\?/).first.split(/\//).last
		link_setup(user,pass,ref,cookie)
		parse_link_info
		# puts @c.username
	end

	def add_links(url_array,user=nil,pass=nil,ref=nil,cookie=nil)
		link_setup(user,pass,ref,cookie)
		url_array.each do |single_url|
			puts single_url.inspect
			# puts single_url.class.inspect
			parse_link_info
			# add to queue
		end
	end
end

manager = Downloader.new("c:\temp")
# manager.add_link("http://www.shapings.com/images/detailed/2/CVNESPT.jpg")
# manager.download(1)
# manager.add_link('http://www.yahoo.com/','http://www.cnn.com/')
# manager.download(2)
manager.add_links(['http://www.yahoo.com/','http://www.cnn.com/'])
manager.add_link('http://www.yahoo.com/','lol')

# urls_to_download.each do |url|

	# filename = url.split(/\?/).first.split(/\//).last

	# uri = Addressable::URI.parse(url)
	# puts uri.scheme
	# puts uri.host
	# puts uri.path
	# filename = uri.path.split(/\//).last
	# if filename.nil? then puts 'ERROR' end
	# c.url = url

	# POBIERANIE

	# c.perform

	# puts c.body_str
	# puts
	# print(uri.host," ",filename," ",dlspeed," (",contenttype,") OK\n")

	# open('file.txt:stream1', 'w') do |f|
 #    	f.puts('Your Text Here')
	# end

	# stream_text = open('file.txt:stream1').read
#
# end