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

		def opts(extras={})
			opts = {}
			opts[:cwd] = args.cwd if args.cwd?
			opts.merge(extras)
		end

    def state
      if args.creates
        {
          :created => args.creates.pathname.exist?
        }
      else # force state changed if we don't have any state comparison to go on
        {
          :time => Time.now.to_i
        }
      end

    end
  end
end
