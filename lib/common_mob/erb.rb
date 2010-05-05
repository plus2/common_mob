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
        when AngryHash
          value
        when Hash
          AngryHash[value]
        else
          value
        end
      end

      def get_binding
        binding
      end
    end

    class ErbError < StandardError
      def initialize(file,ex)
        @file = file
        @src = file.read
        @ex  = ex
      end

      def message
        "error rendering erb: #{@ex.message}\nat line #{line_number+1} of #{@file}\n#{error_with_context * "\n"}"
      end
      def to_s
        message
      end

      def error_with_context(ctx=2)
        start_on_line = [ line_number - ctx - 1, 0          ].max
        end_on_line   = [ line_number + ctx    , @src.length].min

        @src.split("\n")[ start_on_line..end_on_line ]
      end

      def line_number
        @line_number = line_number!
      end
      def line_number!
        re = /\(erb\):(\d+):in `get_binding'/
        @line_number = $1.to_i if @ex.backtrace.find {|line| line =~ re}
      end

      def method_missing(meth,*args,&block)
        @ex.send(meth,*args,&block)
      end
    end

    def render_erb(src,context)
      e = ERB.new(src.read)
      e.result( Context.new(context || {}).get_binding )
    rescue Object
      raise ErbError.new(src, $!)
      #log "error rendering erb: [#{$!.class}] #{$!}"
      #log e.src
      #raise $!
    end
  end
end
