require File.join(File.dirname(__FILE__), *%w[.. .. blather])

module Blather
module Server
  class Client    
    def initialize
      @handlers = {}
      @state    = :started
    end
    
    def write(stanza)
      self.stream.send_data(stanza)
    end
    
    # Close the connection
    def close
      self.stream.close_connection_after_writing
    end
    
    def post_init(stream)  # @private
      @stream = stream
    end
    
    def unbind
      @state = :stopped
    end
    
    def receive_data(stanza)  # @private
      handle_stanza(stanza)
    end
    
    def handle_stanza(stanza)
      stanza.handler_hierarchy.each do |type|
        break if call_handler_for(type, stanza)
      end
    end
    
    def call_handler_for(type, stanza)
      return unless handler = @handlers[type]
      handler.find do |handle|
        catch(:pass) { handle.call(stanza) }
      end
    end
    
    def handle(name, meth = nil, &block)
      prok = meth||block||method("handle_#{name}")
      @handlers[name] ||= []
      @handlers[name] << prok
    end
    
    # Protocol
    
    [:started, :stopped, :ready, :negotiating].each do |state|
      define_method("#{state}?") { @state == state }
    end
    
    def handle_stream(stanza)
      start_stream = <<-STREAM
        <stream:stream
          to='#{stanza.from}'
          xmlns='jabber:client'
          xmlns:stream='http://etherx.jabber.org/streams'
          version='1.0'
          xml:lang='en'
        >
      STREAM
      send start_stream.gsub(/\s+/, ' ')
    end
    handle :stream
  end
end
end