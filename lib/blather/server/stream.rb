module Blather
module Server

  class Stream < EventMachine::Connection
    STREAM_NS = 'http://etherx.jabber.org/streams'

    def self.start(client, host = "0.0.0.0", port = 5222)
      EM.start_server(host, port, self, client)
    end

    def initialize(client)
      super()
      @client = client
      @parser = Parser.new self
    end

    def send_data(stanza)
      Blather.logger.debug "SENDING: (#{caller[1]}) #{stanza}"
      super stanza.respond_to?(:to_xml) ? stanza.to_xml : stanza.to_s
    end

    # Called by EM with data from the wire
    # @private
    def receive_data(data)
      Blather.logger.debug "\n#{'-'*30}\n"
      Blather.logger.debug "STREAM IN: #{data}"
      @parser << data

    rescue ParseError => e
      @error = e
      Blather.logger.debug e
      send_data "<stream:error><xml-not-well-formed xmlns='#{StreamError::STREAM_ERR_NS}'/></stream:error>"
      stop
    rescue => e
      Blather.logger.debug e
      Blather.logger.debug e.backtrace.join("\n")
    end

    # Called by EM after the connection has started
    # @private
    def post_init
      @connected = true
    end

    # Called by EM when the connection is closed
    # @private
    def unbind
      raise NoConnection unless @connected
      @client.receive_data @error if @error
      @client.unbind
    end

    # Called by the parser with parsed nodes
    # @private
    def receive(node)
      Blather.logger.debug "RECEIVING (#{node.element_name}) #{node}"
      @client.receive_data @node.to_stanza
    end
  end  # Stream

end  # Server
end  # Blather
