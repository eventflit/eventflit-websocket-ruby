module EventflitClient
  HOST = 'service.eventflit.com'
  WS_PORT = 80
  WSS_PORT = 443

  def self.logger
    @logger ||= begin
      require 'logger'
      Logger.new(STDOUT)
    end
  end

  def self.logger=(logger)
    @logger = logger
  end
end

require 'eventflit-client/version'
require 'eventflit-client/websocket'
require 'eventflit-client/socket'
require 'eventflit-client/channel'
require 'eventflit-client/channels'
