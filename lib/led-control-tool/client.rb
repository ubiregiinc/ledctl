module LEDControlTool
	class Client
		def initialize(options)
			@socket = options[:socket]
		end

		def send(arg)
			UNIXSocket.open(@socket) do |io|
				io.puts(arg)
				line = io.gets

				if line
					puts line
				end
			end
		end
	end
end
