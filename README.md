# eventflit-client: Ruby WebSocket client for Eventflit service

`eventflit-client` is a Ruby gem for consuming WebSockets from Eventflit service.

## Installation

```sh
gem install eventflit-client
```

This gem is compatible with jruby

## Single-Threaded Usage

The application will pause at `eventflit.connect` and handle events from Eventflit Channels as they happen.

```ruby
require 'eventflit-client'
cluster = 'cus1'  # take this from your app's config in the dashboard
eventflit = EventflitClient::Socket.new(YOUR_APPLICATION_KEY, {
  secure: true,
  ws_host: "ws-#{cluster}.eventflit.com"
})

# Subscribe to two channels
eventflit.subscribe('channel1')
eventflit.subscribe('channel2')

# Subscribe to presence channel
eventflit.subscribe('presence-channel3', USER_ID)

# Subscribe to private channel
eventflit.subscribe('private-channel4', USER_ID)

# Subscribe to presence channel with custom data (user_id is mandatory)
eventflit.subscribe('presence-channel5', :user_id => USER_ID, :user_name => 'john')

# Bind to a global event (can occur on either channel1 or channel2)
eventflit.bind('globalevent') do |data|
  puts data
end

# Bind to a channel event (can only occur on channel1)
eventflit['channel1'].bind('channelevent') do |data|
  puts data
end

eventflit.connect
```

## Asynchronous Usage

With `eventflit.connect(true)`,
the connection to Eventflit Channels will be maintained in its own thread.
The connection will remain open in the background as long as your main application thread is running,
and you can continue to subscribe/unsubscribe to channels and bind new events.

```ruby
require 'eventflit-client'
eventflit = EventflitClient::Socket.new(YOUR_APPLICATION_KEY)
eventflit.connect(true) # Connect asynchronously

# Subscribe to two channels
eventflit.subscribe('channel1')
eventflit.subscribe('channel2')

# Bind to a global event (can occur on either channel1 or channel2)
eventflit.bind('globalevent') do |data|
  puts data
end

# Bind to a channel event (can only occur on channel1)
eventflit['channel1'].bind('channelevent') do |data|
  puts data
end

loop do
  sleep(1) # Keep your main thread running
end
```

## Using native WebSocket implementation

This gem depends on [the `websocket` gem](https://github.com/imanel/websocket-ruby)
which is a pure Ruby implementation of websockets.

However it can optionally use a native C or Java implementation for a 25% speed
increase by including [the `websocket-native` gem](https://github.com/imanel/websocket-ruby-native) in your Gemfile.

## Copyright and license

See `LICENSE.txt`.
