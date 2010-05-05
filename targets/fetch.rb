require 'common_mob'

class Fetch < AngryMob::Target
  include CommonMob::ShellHelper
  include CommonMob::DigestHelper

  def fetch
    log "expected_sha=#{expected_sha}"

    return if before_state[:exists] && (expected_sha && before_state[:sha] == expected_sha)

    sh("curl #{args.src} -L -o #{default_object}".tapp, :cwd => args.cwd).run

    if expected_sha && state[:sha] != expected_sha
      raise "downloaded file's sha didn't match expected sha #{expected_sha} != #{state[:sha]}"
    end
  end

  protected

  def expected_sha
    [ args.sha, args.sha256, args.sha512 ].find {|s| !s.blank?}
  end

  def state
    new_sha = if !args.sha.blank?
                sha(default_object)
              elsif !args.sha256.blank?
                sha256(default_object)
              elsif !args.sha512.blank?
                sha512(default_object)
              end

    {
      :exists => exist?,
      :sha    => new_sha
    }
  end
end
