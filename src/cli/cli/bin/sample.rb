require 'rubygems'
require 'curb'

class Download
  def start
    curl = Curl::Easy.new('http://www.shapings.com/images/detailed/2/CVNESPT.jpg')
    curl.on_body {
      |d| f = File.open('test.zip', 'w') {|f| f.write d}
    }
    curl.perform
  end
end

dl = Download.new
dl.start