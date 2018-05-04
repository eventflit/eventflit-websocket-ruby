require 'spec_helper'

describe "A EventflitClient::Channels collection" do
  before do
    @channels = EventflitClient::Channels.new
  end

  it "should initialize empty" do
    expect(@channels).to be_empty
    expect(@channels.size).to eq(0)
  end

  it "should instantiate new channels added to it by name" do
    @channels << 'TestChannel'
    expect(@channels.find('TestChannel').class).to eq(EventflitClient::Channel)
  end

  it "should allow removal of channels by name" do
    @channels << 'TestChannel'
    expect(@channels['TestChannel'].class).to eq(EventflitClient::Channel)
    @channels.remove('TestChannel')
    expect(@channels).to be_empty
  end

  it "should not allow two channels of the same name" do
    @channels << 'TestChannel'
    @channels << 'TestChannel'
    expect(@channels.size).to eq(1)
  end

end

describe "A EventflitClient::Channel" do
  before do
    @channels = EventflitClient::Channels.new
    @channel = @channels << "TestChannel"
  end

  it 'should not be subscribed by default' do
    expect(@channel.subscribed).to be_falsey
  end

  it 'should not be global by default' do
    expect(@channel.global).to be_falsey
  end

  it 'can have procs bound to an event' do
    @channel.bind('TestEvent') {}
    expect(@channel.callbacks.size).to eq(1)
  end

  it 'should run callbacks when an event is dispatched' do

    @channel.bind('TestEvent') do
      EventflitClient.logger.test "Local callback running"
    end

    @channel.dispatch('TestEvent', {})
    expect(EventflitClient.logger.test_messages).to include("Local callback running")
  end

end

describe "A EventflitClient::Socket" do
  before do
    @socket = EventflitClient::Socket.new(TEST_APP_KEY, :secret => 'secret')
  end

  it 'should not connect when instantiated' do
    expect(@socket.connected).to be_falsey
  end

  it 'should raise ArgumentError if TEST_APP_KEY is an empty string' do
    expect { 
      @broken_socket = EventflitClient::Socket.new('')
    }.to raise_error(ArgumentError)
    expect { 
      @broken_socket = EventflitClient::Socket.new(nil)
    }.to raise_error(ArgumentError)
  end

  describe "...when connected" do
    before do
      @socket.connect
    end

    it 'should know its connected' do
      expect(@socket.connected).to be_truthy
    end

    it 'should know its socket_id' do
      expect(@socket.socket_id).to eq('123abc')
    end

    it 'should not be subscribed to its global channel' do
      expect(@socket.global_channel.subscribed).to be_falsey
    end

    it 'should subscribe to a channel' do
      @channel = @socket.subscribe('testchannel')
      expect(@socket.channels['testchannel']).to eq(@channel)
      expect(@channel.subscribed).to be_truthy
    end

    it 'should unsubscribe from a channel' do
      @socket.subscribe('testchannel')
      @socket.unsubscribe('testchannel')
      expect(EventflitClient.logger.test_messages.last).to include('eventflit:unsubscribe')
      expect(@socket.channels['testchannel']).to be_nil
    end

    it 'should subscribe to a private channel' do
      @channel = @socket.subscribe('private-testchannel')
      expect(@socket.channels['private-testchannel']).to eq(@channel)
      expect(@channel.subscribed).to be_truthy
    end

    it 'should subscribe to a presence channel with user_id' do
      @channel = @socket.subscribe('presence-testchannel', '123')
      expect(@socket.channels['presence-testchannel']).to eq(@channel)
      expect(@channel.user_data).to eq('{"user_id":"123"}')
      expect(@channel.subscribed).to be_truthy
    end

    it 'should subscribe to a presence channel with custom channel_data' do
      @channel = @socket.subscribe('presence-testchannel', :user_id => '123', :user_name => 'john')
      expect(@socket.channels['presence-testchannel']).to eq(@channel)
      expect(@channel.user_data).to eq('{"user_id":"123","user_name":"john"}')
      expect(@channel.subscribed).to be_truthy
    end

    it 'should allow binding of global events' do
      @socket.bind('testevent') { |data| EventflitClient.logger.test("testchannel received #{data}") }
      expect(@socket.global_channel.callbacks.has_key?('testevent')).to be_truthy
    end

    it 'should trigger callbacks for global events' do
      @socket.bind('globalevent') { |data| EventflitClient.logger.test("Global event!") }
      expect(@socket.global_channel.callbacks.has_key?('globalevent')).to be_truthy

      @socket.simulate_received('globalevent', 'some data', '')
      expect(EventflitClient.logger.test_messages.last).to include('Global event!')
    end

    it 'should kill the connection thread when disconnect is called' do
      @socket.disconnect
      expect(Thread.list.size).to eq(1)
    end

    it 'should not be connected after disconnecting' do
      @socket.disconnect
      expect(@socket.connected).to be_falsey
    end

    describe "when subscribed to a channel" do
      before do
        @channel = @socket.subscribe('testchannel')
      end

      it 'should allow binding of callbacks for the subscribed channel' do
        @socket['testchannel'].bind('testevent') { |data| EventflitClient.logger.test(data) }
        expect(@socket['testchannel'].callbacks.has_key?('testevent')).to be_truthy
      end

      it "should trigger channel callbacks when a message is received" do
        # Bind 2 events for the channel
        @socket['testchannel'].bind('coming') { |data| EventflitClient.logger.test(data) }
        @socket['testchannel'].bind('going')  { |data| EventflitClient.logger.test(data) }

        # Simulate the first event
        @socket.simulate_received('coming', 'Hello!', 'testchannel')
        expect(EventflitClient.logger.test_messages.last).to include('Hello!')

        # Simulate the second event
        @socket.simulate_received('going', 'Goodbye!', 'testchannel')
        expect(EventflitClient.logger.test_messages.last).to include('Goodbye!')
      end

    end
  end
end
