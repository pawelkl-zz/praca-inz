require 'rubygems'
require 'mongo'
require 'json'

module AccessDb
	def setup
		@db = Connection.new.db('meta-files');
		setup_collections
	end
	def connect
		@db = Mongo::Connection.new.db('meta',
			:pool_size => 5, :timeout => 5)
	end
	def setup_collections
		@meta = db.collection('meta')
	end
	def insert meta
		@meta.insert(meta)
	end
	def update id, meta
		@meta.update({ :_id => id }, meta)
	end
	def delete id
		@meta.remove({ :_id => id})
	end
	def add id, param, value
		@meta.update({ :_id => id }, '$set' => { param => value })
	end
end


=begin
@conn = Mongo::Connection.new
@db   = @conn['sample-db']
@coll = @db['test']

@coll.remove
3.times do |i|
  @coll.insert({'a' => i+1})
end

puts "There are #{@coll.count} records. Here they are:"
@coll.find.each { |doc| puts doc.inspect }
=end
