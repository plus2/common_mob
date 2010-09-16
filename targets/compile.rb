require 'common_mob'

class Compile < Target
  include CommonMob::ShellHelper

  default_action
  def run
    if needs_rebuild?

      # TODO - remove angry_mob ref
      work_dir  = node.platform.build_dir + default_object

      build_dir = work_dir + 'src'

      build_cmd = build_command

      if node_cfg.url?
        archive   = work_dir + (default_object+ext)
        fetch_opts = {:src => node_cfg.url}

        if node_cfg.sha512?
          fetch_opts[:sha512] = node_cfg.sha512
        elsif node_cfg.sha256?
          fetch_opts[:sha256] = node_cfg.sha256
        end
      else
        archive    = node_cfg.src
        fetch_opts = nil
      end

      act.in_sub_act do
        dir     build_dir

        if fetch_opts
          fetch archive, fetch_opts
        end

        tarball archive, :to => build_dir
        sh(build_cmd, :cwd => build_dir)
      end

      ensure_built!
    end
  end

  def state
    state = {
      :created => create_path_exists?,
      :config_ok => verify_configuration
    }

    state
  end

  protected

  def node_cfg
    @node_cfg ||= args.config || node.platform.compile.send(default_object)
  end

  def ext
    case node_cfg.url.downcase
    when /\.tar\.bz2$/
      '.tar.bz2'
    when /\.tar\.gz$/, /\.tgz$/
      '.tar.gz'
    end
  end

  def needs_rebuild?
    !( before_state[:created] && before_state[:config_ok] )
  end

  def verify_configuration
    return true unless args.verify_configuration?

    begin
      args.verify_configuration.call
    rescue
      false
    end
  end

  def create_path_exists?
    ! Dir[args.creates].empty?
  end

  def ensure_built!
    create_path_exists?   or raise("#{self} failed to create #{args.creates}")
    verify_configuration  or raise("#{self} failed to build with correct configuration")
  end

  def build_command
    args.build_command || "./configure && make install"
  end

  def validate!
    super
    problem!("compile requires :creates arg") unless args.creates?

    problem!("compile requires :config or node.platform.compile.<target name> to be set") unless node_cfg
    problem!("compile config requires either :url or :src") unless node_cfg.url? || node_cfg.src?
  end

end
