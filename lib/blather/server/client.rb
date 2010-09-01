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
      method = "handle_#{type}"
      send(method, stanza) if respond_to?(method)
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
      
      # <stream:features>
      #   <starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'>
      #   </starttls>
      #   <mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
      #     <mechanism>DIGEST-MD5</mechanism>
      #     <mechanism>ANONYMOUS</mechanism>
      #   </mechanisms>
      # </stream:features>
    end
    
    
    # <starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>
    def handle_startls
      # <proceed xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>
    end

    # <auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl'
    #       mechanism='DIGEST-MD5'/>    
    def handle_auth
      # <challenge xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
      # cmVhbG09InNvbWVyZWFsbSIsbm9uY2U9Ik9BNk1HOXRFUUdtMmhoIixxb3A9ImF1dGgi
      # LGNoYXJzZXQ9dXRmLTgsYWxnb3JpdGhtPW1kNS1zZXNzCg==
      # </challenge>
    end
    
    
    # <response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
    # dXNlcm5hbWU9InNvbWVub2RlIixyZWFsbT0ic29tZXJlYWxtIixub25jZT0i
    # T0E2TUc5dEVRR20yaGgiLGNub25jZT0iT0E2TUhYaDZWcVRyUmsiLG5jPTAw
    # MDAwMDAxLHFvcD1hdXRoLGRpZ2VzdC11cmk9InhtcHAvZXhhbXBsZS5jb20i
    # LHJlc3BvbnNlPWQzODhkYWQ5MGQ0YmJkNzYwYTE1MjMyMWYyMTQzYWY3LGNo
    # YXJzZXQ9dXRmLTgK
    # </response>

    # <response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>
    def handle_response
      # 1)
      # <challenge xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
      # cnNwYXV0aD1lYTQwZjYwMzM1YzQyN2I1NTI3Yjg0ZGJhYmNkZmZmZAo=
      # </challenge>
      # 
      # 2)
      # <success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>
      
    end
    
  end
end
end