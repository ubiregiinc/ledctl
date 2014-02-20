module LEDControlTool
  class CLI < Thor
    BLINK_INTERVAL = 1000

    class_option :sock, :default => "/var/run/ledctl.sock", :desc => "Path for unix socket for communication"

    desc "server PINNO", "Start LEDControlTool server"
    option :daemon, :type => :boolean, :desc => "Make server run as a Daemon"
    option :initwith, :type => :string, :desc => "Start ledctl server with the command", :banner => "command", :default => "on"
    def server(pinno)
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

    	LEDControlTool::Server.new(:pinno => pinno.to_s, :socket => options[:sock]).start do |server|
        case options[:initwith]
        when "on"
          server.current_command = LEDControlTool::Server::OnCommand.new(server)
        when "off"
          server.current_command = LEDControlTool::Server::OffCommand.new(server)
        when "blink"
          server.current_command = LEDControlTool::Server::BlinkCommand.new(server, BLINK_INTERVAL)
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
    option :interval, :type => :numeric, :desc => "Specify how fast the LED will flush", :banner => "ms", :default => BLINK_INTERVAL
    def blink
      interval = options[:interval]
      LEDControlTool::Client.new(:socket => options[:sock]).send("blink #{interval}")
    end
  end
 end