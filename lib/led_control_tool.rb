require "thor"
require "socket"
require "pathname"

require "led_control_tool/server"
require "led_control_tool/client"

class Pathname
	def write(*args)
		self.open('w') {|io| io.write(*args) }
	end
end
