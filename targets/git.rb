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

      git("fetch -u -f #{args.repo} *:*" ).run
      git("reset --hard #{ref}").run

      ui.log "repo at #{git("rev-parse HEAD").to_s}"
      ui.log git("log HEAD^.. --shortstat --decorate").to_s

    rescue
      ui.exception! $!
      raise $! unless args.swallow_errors?
    end
  end


  def create
    log "cloning"

    begin
      # XXX consider moving clone to init-then-update
      git("clone -o #{remote} #{args.repo} #{default_object}", :cwd => default_object.parent).run
      update

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
  end


  def default_object
    args.default_object.pathname
  end


  def remote
    'origin'
  end


  def ref
    @ref ||= full_ref #args.sha || args.ref || resolve_ref
  end


  def resolve_ref
    git("ls-remote #{args.repo} #{full_ref}").to_s.split("\n").first.split(/\s+/,2).first
  end


  def full_ref
    if branch = args.branch
      "refs/heads/#{branch}"
    elsif tag = args.tag
      "refs/tags/#{tag}"
    else
      args.sha || args.ref
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
