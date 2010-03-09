targets('common-service') do
  require 'common_mob'

  TargetHelpers do
    include CommonMob::ShellHelper
  end


  SingletonTarget(:service) do
    default_action :enable do
      unless before_state[:enabled]
        sh("/usr/sbin/update-rc.d #{name} defaults").run
        log "enabled service #{nickname}"
      end
    end

    action :disable do
      if before_state[:enabled]
        sh("/usr/sbin/update-rc.d -f #{name} remove").run
        log "disabled service #{nickname}"
      end
    end

    action :start do
      initd('start')
      ensure_running!
    end

    action :stop do
      initd('stop')
    end

    action :restart do
      initd('restart')
      ensure_running!
    end

    action :reload do
      initd('reload')
      ensure_running!
    end

    def state
      enabled = sh("/usr/sbin/update-rc.d -n -f #{name} remove").to_s[%r[/etc/rc\d+.d/]]

      {
        :enabled => enabled
      }
    end

		def name
			nickname
		end


    def initd(command)
      begin
        sh("/etc/init.d/#{name} #{command}").run
      rescue CommonMob::ShellError
        if raise_on_failed_initd?
          raise $!
        else
          log "/etc/init.d/#{name} #{command} failed (but swallowing exception)"
        end
      end
    end

    def raise_on_failed_initd?
      false
    end

    def ensure_running!
      unless sh("/etc/init.d/#{name} status").ok?
        raise "#{name} should be running but isn't"
      end
      log "#{name} is running"
    end

  end
end
