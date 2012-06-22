require 'rubygems'
require 'mongo'
require 'json'

module AccessDb
	def AccessDb.setup
		@db = Connection.new.db('meta-files');
		setup_collections
	end
	def AccessDb.connect
		@db = Mongo::Connection.new.db('meta',
			:pool_size => 5, :timeout => 5)
	end
	def AccessDb.setup_collections
		@meta = db.collection('meta')
	end
	def AccessDb.insert meta
		# id = @meta.insert(meta)
		# TODO:
		# odczytanie z mety hasha i probowanie znalezienie w bazie tego elementu i dopiero wtedy dodanie poprzez uzycie upserta (3 arg true)
		@meta.update({ :hash => hash}, meta, true) # upsert!
		# @meta.update({ :_id => id }, '$set' => { db_id => id })
	end
	def AccessDb.update id, meta
		@meta.update({ :_id => id }, meta, true) # upsert!
	end
	def AccessDb.delete id
		@meta.remove({ :_id => id})
	end
	def AccessDb.add id, param, value
		@meta.update({ :_id => id }, '$set' => { param => value })
		# @meta.find_and_modify(:_ibd => id)
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
