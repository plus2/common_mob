targets('common-git') do
  require 'common_mob'
  TargetHelpers do
    include CommonMob::ShellHelper
  end

  Target(:git) do
    default_action :sync do
      if is_git?
        update
      else
        create
      end
    end

    action :update do
      log "updating"

      set_repo

      git("fetch").run
      git("reset --hard #{ref}").run
    end

    action :create do
      log "cloning"
      git("clone -o origin #{args.repo} #{default_object}", :cwd => default_object.parent).run
    end

    def changed
      if args.enable_submodules?
        git("submodule update --init").ok?
      end
    end

    def is_git?
      exist? && git('rev-parse --is-inside-work-tree').to_s == "true"
    rescue CommonMob::ShellError
    end

    def git(*cmd)
      cmd.options[:cwd] ||= default_object
      cmd[0] = "git #{cmd.first}"
      sh(*cmd)
    end

    def set_repo
      git("config remote.origin.url #{args.repo}").run
      # TODO write merge spec
      # git("config branch.master.remote origin").run
    end

    def default_object
      args.default_object.pathname
    end

    def ref
      args.ref || args.branch || 'HEAD'
    end

    def revision
      exist? && git('rev-parse HEAD').to_s
    rescue CommonMob::ShellError
    end

    def state
      {
        :revision => revision
      }
    end

    def validate!
      problem!("no git repo defined") unless args.repo?
    end
  end
end
