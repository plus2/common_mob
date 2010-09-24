require 'common_mob'

unless defined?(Template)
  class Template < AngryMob::Target
    include CommonMob::FileHelper

    default_action
    def create
      new_content = render_template(source,variables)

      if sha512(new_content) != before_state[:sha512]
        log "template has changed, overwriting"

        backup_file(default_object)

        default_object.open('w') {|f| f << new_content}
      end

      set_file_ownership
    end

    protected

    def default_object
      Pathname(super)
    end

    def source
      @source ||= if args.src?
                    resource(args.src)
                  else
                    StringIO.new(args.string)
                  end
    end

    def variables
      @variables ||= (args.variables || args.vars || AngryHash.new).tap {|vars|
                      vars.node = node
      }
    end

    def state
      {
        :sha512 => sha512(default_object)
      }
    end

    def validate!
      super

      if args.src?
        src = source
        problem!(":src #{src} doesn't exist" ) unless src.exist?
        problem!(":src #{src} isn't a file"  ) unless src.file?
        problem!(":src #{src} isn't readable") unless src.readable?
      else
        problem!("Please specify either :src or :string") unless args.string?
      end
    end
  end
end
