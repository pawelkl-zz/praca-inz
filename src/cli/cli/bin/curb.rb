require 'rubygems'
require 'curb'
require 'addressable/uri'

class QueueItem
	def initialize(url)
		@url = url
		
	end

	def url=(u)
		set :url, u
	end


end

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

PASS = nil
COOKIE = nil

c = Curl::Easy.new # (url)

urls_to_download.each do |url|

	uri = Addressable::URI.parse(url)

	# puts uri.scheme
	# puts uri.host
	# puts uri.path

	c.url = url

	# USTAWIENIA GLOBALNE
	c.dns_cache_timeout = 8
	c.fetch_file_time = true
	c.verbose = false

	# USTAWIENIA ¯¥DANIA
	# c.username = user
	# c.userpwd = user:password
	# c.password = PASS
	c.autoreferer=true
	c.connect_timeout=15
	c.cookiefile = COOKIE
	# c.cookiejar = COOKIEJAR
	# s.cookies=COOKIES # NAME=CONTENTS;


	# POBIERANIE
	contenttype = c.content_type
	filetime = c.file_time
	dlspeed = c.download_speed
	content_length = c.downloaded_content_length

	c.perform

	# puts c.body_str
	# puts
	print(uri.host," ",dlspeed," (",contenttype,") OK\n")

	# open('file.txt:stream1', 'w') do |f|
 #    	f.puts('Your Text Here')
	# end

	# stream_text = open('file.txt:stream1').read
	j 
end