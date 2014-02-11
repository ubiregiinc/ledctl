module LEDControlTool
  class CLI < Thor
    class_option :sock, :default => "/var/run/ledctl.sock", :desc => "Path for unix socket for communication"

    desc "server", "Start LEDControlTool server"
    option :daemon, :type => :boolean, :desc => "Make server run as a Daemon"
    def server(pinno)
    	LEDControlTool::Server.new(:pinno => pinno.to_s, :socket => options[:sock]).start do
        if options[:daemon]
          puts "Should daemonize here"
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