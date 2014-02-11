module LEDControlTool
	class Server
		class OnCommand
			def initialize(server)
				@server = server
				@server.on!
			end

			def tick!(step)
			end

			def status
				"on"
			end
		end

		class OffCommand
			def initialize(server)
				@server = server
				server.off!
			end

			def tick!(step)
			end

			def status
				"off"
			end
		end

		class BlinkCommand
			def initialize(server, interval)
				@server = server
				@interval = interval

				@count = 0
				@on = true

				@server.on!
			end

			def tick!(step)
				@count += step
				if @count > @interval
					if @on
						@server.off!
					else
						@server.on!
					end

					@count = 0
					@on = !@on
				end
			end

			def status
				"blink #{@interval}"
			end
		end

		def initialize(options)
			@pinno = options[:pinno]
			@socket = options[:socket]
		end

		def dir
			Pathname("/sys/class/gpio/gpio#{@pinno}")
		end

		def export!
			Pathname("/sys/class/gpio/export").write(@pinno)
		end

		def unexport!
			Pathname("/sys/class/gpio/unexport").write(@pinnno)
		end

		def out!
			(dir+"direction").write("out")
		end

		def on!
			(dir+"value").write("1")
		end

		def off!
			(dir+"value").write("0")
		end

		def run!
			Thread.start do
				while true
					command = @current_command
					command.tick!(50) if command

					sleep 0.05
				end
			end
		end

		def start
			begin
				export!
				out!

				run!

				UNIXServer.open(@socket) do |server|
					File.chmod(0666, @socket)
					
					yield if block_given?

					@current_command = OnCommand.new(self)

					while true
						socket = server.accept

						command = socket.gets.chomp.split
						case command.first
						when "on"
							@current_command = OnCommand.new(self)
						when "off"
							@current_command = OffCommand.new(self)
						when "blink"
							@current_command = BlinkCommand.new(self, command[1].to_i)
						when "status"
							socket.puts @current_command.status
						end

						socket.close
					end
				end
			ensure
				unexport!
				File.unlink(@socket) if File.file?(@socket)
			end
		end
	end
end
