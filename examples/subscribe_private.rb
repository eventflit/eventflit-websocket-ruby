# Usage: $ EVENTFLIT_KEY=YOURKEY ruby examples/subscribe_private.rb

$:.unshift(File.expand_path("../../lib", __FILE__))
require 'eventflit-client'
require 'pp'

APP_KEY = ENV['EVENTFLIT_KEY'] # || "YOUR_APPLICATION_KEY"
APP_SECRET = ENV['EVENTFLIT_SECRET'] # || "YOUR_APPLICATION_SECRET"

socket = EventflitClient::Socket.new(APP_KEY, { :encrypted => true, :secret => APP_SECRET } )

# Subscribe to a channel
socket.subscribe('private-helloeventflit')

# Bind to a channel event
socket['helloeventflit'].bind('hello') do |data|
  pp data
end

socket.connect
