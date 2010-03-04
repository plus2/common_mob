targets('common-user') do
  require 'common_mob'
  require 'etc'

  TargetHelpers do
    include CommonMob::ShellHelper
  end

  Target(:user) do

    default_action :ensure do
      if before_state[:exists] then update else create end
    end

    action :create do
      opt_string = opts

      unless opt_string.blank?
        log "creating #{default_object}"
        sh("useradd #{opts} #{default_object}").run
      end
    end

    action :update do
      opt_string = opts

      unless opt_string.blank?
        log "updating #{default_object}"
        sh("usermod #{opts} #{default_object}").run
      end
    end

    action :delete do
    end

    action :lock do
    end

    action :unlock do
    end

    def state
      begin
        user = Etc.getpwnam(default_object)
        {
          :exists  => true,
          :uid     => user.uid,
          :gid     => user.gid,
          :comment => user.gecos,
          :home    => user.dir,
          :shell   => user.shell
        }
      rescue ArgumentError => e
        {
          :exists => false
        }
      end
    end


    def default_object
      super.to_s
    end

    def validate!
      super
      problem!("username is blank") if default_object.blank?
    end

    protected
    def opts
      opts = ''
      switches = {
        :comment => '-c',
        :gid     => '-g',
        :uid     => '-u',
        :shell   => '-s',
        :set_home => lambda {|value| "-d '#{value}'"   },
        :home     => lambda {|value| "-d '#{value}' -m"}
      }

      switches.each do |(key,switch)|
        to_value = args.__send__(key)

        if !to_value.nil? && to_value != before_state[key]
          if switch.respond_to?(:call)
            opts << switch.call(to_value)
          else
            opts << " #{switch} '#{to_value}'"
          end
          opts << ' '
        end
      end

      opts
    end
  end
end
