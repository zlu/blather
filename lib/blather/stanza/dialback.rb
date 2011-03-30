module Blather
class Stanza
  class Dialback < Stanza
    # <db:result
    #     from='type1.lit'
    #     to='example.lit'>
    #   some-long-dialback-key
    # </db:result>
    # 
    # <db:result
    #   from='target.tld'
    #   to='sender.tld'
    #   type='valid'/>    
    
    register :dialback, :"db:result"
    
    VALID_TYPES = [ :valid,
                    :invalid,
                    :error ].freeze

    def key
      self.content
    end
    
    def key=(key)
      self.content = key
    end
    
    def type=(type)
      if type && !VALID_TYPES.include?(type.to_sym)
        raise ArgumentError, "Invalid Type (#{type}), use: #{VALID_TYPES*' '}"
      end
      super
    end
  end
end
end