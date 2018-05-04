# Usage: $ EVENTFLIT_KEY=YOURKEY ruby examples/hello_eventflit.rb

$:.unshift(File.expand_path("../../lib", __FILE__))
require 'eventflit-client'
require 'pp'

APP_KEY = ENV['EVENTFLIT_KEY'] # || "YOUR_APPLICATION_KEY"

socket = EventflitClient::Socket.new(APP_KEY)

# Subscribe to a channel
socket.subscribe('helloeventflit')

# Bind to a channel event
socket['helloeventflit'].bind('hello') do |data|
  pp data
end

socket.connect
