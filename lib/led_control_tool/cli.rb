module LEDControlTool
  class CLI < Thor
    BLINK_INTERVAL = 1000

    class_option :sock, :default => "/var/run/ledctl.sock", :desc => "Path for unix socket for communication"

    desc "server PINNO", "Start LEDControlTool server"
    option :initwith, :type => :string, :desc => "Start ledctl server with the command", :banner => "command", :default => "on"
    def server(pinno)
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
      puts LEDControlTool::Client.new(:socket => options[:sock]).status
    end

    desc "on", "On the LED"
    def on
      LEDControlTool::Client.new(:socket => options[:sock]).on
    end

    desc "off", "Off the LED"
    def off
      LEDControlTool::Client.new(:socket => options[:sock]).off
    end

    desc "blink", "Blink the LED"
    option :interval, :type => :numeric, :desc => "Specify how fast the LED will flush", :banner => "ms", :default => BLINK_INTERVAL
    def blink
      interval = options[:interval]
      LEDControlTool::Client.new(:socket => options[:sock]).blink(interval)
    end
  end
 end
