require 'common_mob'

module CommonMob
  class Apt < AngryMob::Target
    include CommonMob::ShellHelper

    default_action :install do
      if args.version && !before_state[:version_matches]
        # TODO - install with version
        sh("apt-get install -y #{default_object}").run
      elsif !before_state[:installed]
        sh("apt-get install -y #{default_object}").run
      else
        log "no need to install #{default_object}"
      end
    end

    action :upgrade do
    end

    action :uninstall do
      if before_state[:installed]
        sh("apt-get remove -y #{default_object}").run
      end
    end

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
      if?('installable') { before_state[:installable] }
    end

  end

  class Gem < AngryMob::Target
    include CommonMob::ShellHelper

    default_action :install do
      gemsh("install #{default_object} #{gem_version}").run unless before_state[:installed]
    end

    action :upgrade do
      gemsh("update #{default_object}").run
    end

    action :uninstall do
    end

    def state
      {
        :installed => installed?
      }
    end

    def gem_version
      args.version.blank? ? '' : " -v '#{args.version}'"
    end

    # works around bundler being a bit pushy
    def gemsh(*args)
      args[0] = "gem #{args[0]}"
      sh(*args)
    end

    def installed?
      gemsh("list -i #{gem_version} #{default_object}").to_s.strip == 'true'
    end
  end
end
