targets('common-shell') do
  require 'common_mob'

  TargetHelpers do
    include CommonMob::ShellHelper
  end

  Target(:sh) do
    default_action :execute do
      if ! before_state[:created]
        sh(default_object, opts.tapp(:opts)).run
      end
    end

		def opts
      opts = AngryMob::AngryHash[ args ]

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
