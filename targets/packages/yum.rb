require 'common_mob'

class Yum < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def install
    if args.version? && !before_state[:version_matches]
      yum("install #{default_object}-#{args.version}").run

    elsif !before_state[:installed]
      if args.version?
        yum("install #{default_object}-#{args.version}").run
      else
        yum("install #{default_object}").run
      end

    else
      log "no need to install #{default_object}"
    end
  end

  def uninstall
  end

  protected
  def yum(cmd)
    sh("yum -d0 -e0 -y #{cmd}")
  end

  def available_re 
    %r[
      ^
      #{Regexp.escape(default_object)}
      \.
      \S+   # arch
      \s+
      (\S+) # version
      \s+
      (.*)  # state
      $
    ]x
  end
  def state
    begin
      match = yum("list #{default_object}").to_s.match(available_re)

      {
        :installed       => $2 == 'installed',
        :version_matches => ($1 == args.version),
        :installable     => true
      }
    rescue CommonMob::ShellError
      {
        :installed => false,
        :version_matches => false,
        :installable => false
      }
    end
  end
 
end
