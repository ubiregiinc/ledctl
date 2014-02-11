module LEDControlTool
  class CLI < Thor
    class_option :sock, :default => "/var/run/ledctl.sock", :desc => "Path for unix socket for communication"

    desc "server", "Start LEDControlTool server"
    option :daemon, :type => :boolean, :desc => "Make server run as a Daemon"
    option :initial, :type => :string, :desc => "Initial command", :default => "on", :banner => "on|off"
    def server(pinno)
    	LEDControlTool::Server.new(:pinno => pinno.to_s, :socket => options[:sock]).start do |server|
        if options[:daemon]
          pidfile = Pathname.new("/var/run/ledctl.pid")

          if pidfile.file?
            puts "Aborting: #{pidfile} already exist; maybe already running?"
            exit
          end

          Process.daemon

          pidfile.open('w') do |io|
            io.puts(Process.pid)
          end

          at_exit do
            pidfile.unlink if pidfile.file?
          end
        end

        case options[:initial]
        when "on"
          server.current_command = LEDControlTool::Server::OnCommand.new(self)
        when "off"
          server.current_command = LEDControlTool::Server::OffCommand.new(self)
        end
      end
    end

    desc "status", "Status of the LED under the control of LEDcontrolTool"
    def status
      puts LEDControlTool::Client.new(:socket => options[:sock]).send("status")
    end

    desc "on", "On the LED"
    def on
      LEDControlTool::Client.new(:socket => options[:sock]).send("on")
    end

    desc "off", "Off the LED"
    def off
      LEDControlTool::Client.new(:socket => options[:sock]).send("off")
    end

    desc "blink", "Blink the LED"
    option :interval, :type => :numeric, :desc => "Specify how fast the LED will flush", :banner => "ms", :default => 1000
    def blink
      interval = options[:interval]
      LEDControlTool::Client.new(:socket => options[:sock]).send("blink #{interval}")
    end
  end
 end