module MovieHasher

  CHUNK_SIZE = 64 * 1024 # in bytes

  def self.compute_hash(filename)
    filesize = File.size(filename)
    hash = filesize

    # Read 64 kbytes, divide up into 64 bits and add each
    # to hash. Do for beginning and end of file.
    File.open(filename, 'rb') do |f|
      # Q = unsigned long long = 64 bit
      f.read(CHUNK_SIZE).unpack("Q*").each do |n|
        hash = hash + n & 0xffffffffffffffff # to remain as 64 bit number
      end

      f.seek([0, filesize - CHUNK_SIZE].max, IO::SEEK_SET)

      # And again for the end of the file
      f.read(CHUNK_SIZE).unpack("Q*").each do |n|
        hash = hash + n & 0xffffffffffffffff
      end
    end

    sprintf("%016x", hash)
  end
end

if __FILE__ == $0
  require 'test/unit'

  class MovieHasherTest < Test::Unit::TestCase
    def test_compute_hash
      assert_equal("8e245d9679d31e12", MovieHasher::compute_hash('breakdance.avi'))
    end

    def test_compute_hash_large_file
      assert_equal("61f7751fc2a72bfb", MovieHasher::compute_hash('dummy.bin'))
    end

    def test_jpeg
      assert_equal("bed5a0ecf41d0d96", MovieHasher::compute_hash('2638909.jpg')) # => bed5a0ecf41d0d96, zle 8228bb57b5b72510
    end
  end
end