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
					puts line.chomp
				end
			end
    end

    def on
      send("on")
    end

    def off
      send("off")
    end

    def blink(interval=1000)
      send("blink #{interval}")
    end

    def status
      send("status")
    end
	end
end
