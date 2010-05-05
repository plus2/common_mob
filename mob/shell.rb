targets('common-shell') do
  require 'common_mob'

  TargetHelpers do
    include CommonMob::ShellHelper
  end

  Target(:sh) do
    default_action :execute do
      if ! before_state[:created]
        begin
          sh(default_object, opts).run
        rescue CommonMob::ShellError
          if args.swallow_error?
            log "command failed, but ignoring"
          else
            raise $!
          end
        end
      end
    end

		def opts
      opts = AngryHash[ args ]

      opts.delete_all_of(%w{notify action default_object creates})

			opts
		end

    def state
      if args.creates
        {
          :created => args.creates.pathname.exist?
        }
      else # force state changed if we don't have any state comparison to go on
        {
          :rand => rand
        }
      end

    end
  end
end
