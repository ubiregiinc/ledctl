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
      attr_reader :interval

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

		attr_accessor :current_command

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
					command = self.current_command
					command.tick!(50) if command

					sleep 0.05
				end
			end
		end

		def ensure_socket_deleted
			st = begin
				File.lstat(@socket)
		    rescue Errno::ENOENT
			    nil
			end
			if st && st.socket? && st.owned?
			    File.unlink @socket
			end
		end

		def start
			begin
				ensure_socket_deleted

				export!
				out!

				run!

				UNIXServer.open(@socket) do |server|
					File.chmod(0666, @socket)

					yield(self) if block_given?

					while true
						socket = server.accept

						command = socket.gets.chomp.split

						case command.first
              when "on"
                self.current_command = OnCommand.new(self)
              when "off"
                self.current_command = OffCommand.new(self)
              when "blink"
                self.current_command = BlinkCommand.new(self, command[1].to_i)
              when "status"
                socket.puts self.current_command.status
              when "quit"
                break
						end

						socket.close
					end
				end
			ensure
				off!
				unexport!
			end
		end
	end
end
