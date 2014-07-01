require "spec_helper"

describe LEDControlTool::Server do
  after :each do
    FileUtils.rmtree(path)
  end

  let (:path) { Pathname(Dir.mktmpdir) }
  let (:socket_path) { path + "led.sock" }
  let (:server) { LEDControlTool::Server.new(pinno: 23, socket: socket_path.to_s) }

  before :each do
    stub(server).on!
    stub(server).off!
    stub(server).export!
    stub(server).unexport!
    stub(server).out!
  end

  describe "#start" do
    it "create unix socket on #socket" do
      Thread.start do
        server.start
      end

      sleep 0.1

      expect(socket_path).to be_socket
    end

    it "yields given block when socket is ready" do
      Thread.start do
        server.start do
          expect(socket_path).to be_socket
        end
      end

      sleep 0.1
    end
  end

  describe "it accepts command through socket" do
    describe "on command" do
      it "sets on command" do
        mock(server).current_command= is_a(LEDControlTool::Server::OnCommand)
        Thread.start do
          server.start
        end

        sleep 0.1

        UNIXSocket.new(socket_path.to_s).puts("on")

        sleep 0.1
      end
    end

    describe "off command" do
      it "sets off command" do
        mock(server).current_command= is_a(LEDControlTool::Server::OffCommand)
        Thread.start do
          server.start
        end

        sleep 0.1

        UNIXSocket.new(socket_path.to_s).puts("off")

        sleep 0.1
      end
    end

    describe "blink command" do
      it "sets blink command with arguments" do
        Thread.start do
          server.start
        end

        sleep 0.1

        UNIXSocket.new(socket_path.to_s).puts("blink 1000")

        sleep 0.1

        expect(server.current_command).to be_a(LEDControlTool::Server::BlinkCommand)
        expect(server.current_command.interval).to eq(1000)
      end

      it "sets blink command without arguments" do
        Thread.start do
          server.start
        end

        sleep 0.1

        UNIXSocket.new(socket_path.to_s).puts("blink")

        sleep 0.1

        expect(server.current_command).to be_a(LEDControlTool::Server::BlinkCommand)
        expect(server.current_command.interval).to eq(0)
      end
    end
  end
end
