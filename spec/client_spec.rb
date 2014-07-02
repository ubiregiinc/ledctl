require "spec_helper"

describe LEDControlTool::Server do
  after :each do
    FileUtils.rmtree(path)
  end

  let (:path) { Pathname(Dir.mktmpdir) }
  let (:socket_path) { path + "led.sock" }
  let (:client) { LEDControlTool::Client.new(socket: socket_path.to_s) }

  describe "#send" do
    it "writes to socket" do
      queue = Queue.new

      Thread.start do
        UNIXServer.open(socket_path.to_s) do |server|
          File.chmod(0666, socket_path.to_s)

          socket = server.accept
          queue << socket.gets.chomp
          socket.close
        end
      end

      sleep 0.1
      client.send("hogehoge")

      expect(queue.pop).to eq("hogehoge")
    end
  end
end

