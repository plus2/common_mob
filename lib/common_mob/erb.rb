require 'erb'

module CommonMob
  module Erb
    class Context
      def initialize(hash)
        hash.each do |k,v|
          instance_variable_set("@#{k}", convert_value(v))
        end
      end

      def convert_value(value)
        case value
        when AngryMob::AngryHash
          value
        when Hash
          AngryMob::AngryHash[value]
        else
          value
        end
      end

      def get_binding
        binding
      end
    end

    def render_erb(src,context)
      e = ERB.new(src.read)
      e.result( Context.new(context || {}).get_binding )
    rescue Object
      log "error rendering erb: [#{$!.class}] #{$!}"
      raise $!
    end
  end
end
