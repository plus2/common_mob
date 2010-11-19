require 'common_mob'

class Git < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def sync
    if is_git?
      update
    else
      create
    end
  end

  def update
    log "updating"

    begin
      set_repo

      git("fetch").run
      git("reset --hard #{ref}").run

    rescue
      ui.exception! $!
      raise $! unless args.swallow_errors?
    end
  end

  def create
    log "cloning"

    begin
      git("clone -o #{remote} #{args.repo} #{default_object}", :cwd => default_object.parent).run
      git("reset --hard #{ref}").run

    rescue
      ui.exception! $!
      raise $! unless args.swallow_errors?
    end
  end

  protected

  def changed
    unless FalseClass === args.enable_submodules
      git("submodule update --init").ok?
    end
  end

  def is_git?
    exist? && git('rev-parse --is-inside-work-tree').to_s == "true"
  rescue CommonMob::ShellError
  end

  def git(*cmd)
    cmd.options[:cwd] ||= default_object
    cmd.options[:as] = args.as if args.as?
    cmd[0] = "git #{cmd.first}"
    sh(*cmd)
  end

  def set_repo
    git("config remote.#{remote}.url #{args.repo}").run
    # TODO write merge spec
    # git("config branch.master.remote origin").run
  end

  def default_object
    args.default_object.pathname
  end

  def remote
    'origin'
  end

  def ref
    if base_ref = args.ref || args.branch
      "#{remote}/#{base_ref}"
    elsif ref = args.tag || args.sha || args.revision
      ref
    end
  end

  def revision
    exist? && git("rev-parse HEAD").to_s
  rescue CommonMob::ShellError
  end

  def state
    {
      :revision => revision
    }
  end

  def validate!
    problem!("no git repo defined") unless args.repo?
    problem!("no git path defined") unless args.default_object?
  end
end
