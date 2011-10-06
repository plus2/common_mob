require 'common_mob'

class Apt < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def install
    if args.version && !before_state[:version_matches]
      # TODO - install with version
      sh("apt-get install -y #{package}", :environment => {'DEBIAN_FRONTEND' => "noninteractive"}).run

    elsif !before_state[:installed]
      sh("apt-get install -y #{package}", :environment => {'DEBIAN_FRONTEND' => "noninteractive"}).run

    else
      log "no need to install #{package}"

    end
  end


  def upgrade
  end


  def uninstall
    if before_state[:installed]
      sh("apt-get remove -y #{package}").run
    end
  end


  protected


  def package; default_object end


  def state
    version = policy[/^\s+Installed: (.*)$/, 1]

    {
      :installed       => (version != '(none)'),
      :version_matches => (version == args.version),
      :installable     => !version.nil?
    }
  end


  def validate!
    out,err = sh(policy_cmd).output

    if err[/Unable to locate package/]
      problem!("package #{package} doesn't exist")
    end
  end


  def policy_cmd
    "apt-cache policy #{package}"
  end


  def policy
    sh(policy_cmd).to_s
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

