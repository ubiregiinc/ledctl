require "thor"
require "socket"

require "led-control-tool/server"
require "led-control-tool/client"
require "led-control-tool/cli"

class Pathname
	def write(*args)
		self.open('w') {|io| io.write(*args) }
	end
end
