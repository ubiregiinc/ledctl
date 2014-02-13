require "thor"
require "socket"
require "pathname"

require "led-control-tool/server"
require "led-control-tool/client"

class Pathname
	def write(*args)
		self.open('w') {|io| io.write(*args) }
	end
end
