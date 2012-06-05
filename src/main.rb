require 'wx'
require 'rubygems'
include Wx

class MinimalApp < App
   def on_init
    Frame.new(nil, -1, "Simple downloader",nil,Size.new(600,480)).show()
   end
end



MinimalApp.new.main_loop

exit!