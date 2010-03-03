targets('common-fetch') do
  require 'common_mob'

  TargetHelpers do
    include CommonMob::ShellHelper
    include CommonMob::DigestHelper
	end

	Target(:fetch) do
		default_action :fetch do

      log "expected_sha=#{expected_sha}"

			return if before_state[:exists] && (expected_sha && before_state[:sha] == expected_sha)

			sh("curl #{args.src} -o #{default_object}".tapp, :cwd => args.cwd).run

      if expected_sha && state[:sha] != expected_sha
        raise "downloaded file's sha didn't match expected sha #{expected_sha} != #{state[:sha]}"
      end
		end

    def expected_sha
      args.sha || args.sha256 || args.sha512
    end

		def state
      new_sha = if args.sha
                  sha(default_object)
                elsif args.sha256
                  sha256(default_object)
                elsif args.sha512
                  sha512(default_object)
                end

			{
				:exists => exist?,
				:sha    => new_sha
			}
		end
	end
end

