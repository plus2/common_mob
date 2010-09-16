require 'common_mob'

class Apt < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def install
    if args.version && !before_state[:version_matches]
      # TODO - install with version
      sh("apt-get install -y #{default_object}").run
    elsif !before_state[:installed]
      sh("apt-get install -y #{default_object}").run
    else
      log "no need to install #{default_object}"
    end
  end

  def upgrade
  end

  def uninstall
    if before_state[:installed]
      sh("apt-get remove -y #{default_object}").run
    end
  end

  protected

  def state
    version = sh("apt-cache policy #{default_object}").to_s[/^\s+Installed: (.*)$/, 1]

    {
      :installed       => (version != '(none)'),
      :version_matches => (version == args.version),
      :installable     => !version.nil?
    }
  end

  protected
  def before_call
    skip! unless before_state[:installable]
  end

end

class AptSource < AngryMob::Target
  include CommonMob::ShellHelper
  default_action
  def install
    act.in_sub_act { apt 'python-software-properties' }
    # TODO make null op less expensive
    sh("add-apt-repository #{default_object} && apt-get update").run
  end
end

