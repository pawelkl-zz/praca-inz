require 'typhoeus'

def write_file(filename, data)
    file = File.new(filename, "wb")
    file.write(data)
    file.close
      # ... some other stuff
end

hydra = Typhoeus::Hydra.new(:max_concurrency => 20)

batch_urls = ['http://static3.blip.pl/user_generated/update_pictures/2639011.jpg',
	'http://3.asset.soup.io/asset/3187/8131_3a06.jpeg',
	'http://e.asset.soup.io/asset/3182/1470_9f47_500.jpeg']

batch_urls.each do |url_info|
    req = Typhoeus::Request.new(url_info[:url])
    req.on_complete do |response|
      write_file(url_info[:file], response.body)
    end
    hydra.queue req
end

hydra.run