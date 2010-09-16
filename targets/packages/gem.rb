class GemPackage < AngryMob::Target
  nickname 'gem'

  include CommonMob::ShellHelper

  default_action
  def install
    gemsh("install #{source} #{gem_version}").run unless before_state[:installed]
  end

  def upgrade
    gemsh("update #{source}").run
  end

  def uninstall
  end

  protected

  def state
    {
      :installed => installed?
    }
  end

  def source
    if args.path? then args.path else default_object end
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
