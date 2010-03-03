targets('common-service') do
  require 'common_mob'

  TargetHelpers do
    include CommonMob::ShellHelper
  end


  SingletonTarget(:service) do
    default_action :enable do
      unless before_state[:enabled]
        sh("/usr/sbin/update-rc.d #{ame} defaults").run
        log "enabled service #{nickname}"
      end
    end

    action :disable do
      if before_state[:enabled]
        sh("/usr/sbin/update-rc.d -f #{name} remove").run
        log "disabled service #{nickname}"
      end
    end

    def initd(command)
      sh("/etc/init.d/#{name} #{command}").run
    end

    action :start do
      initd('start')
    end

    action :stop do
      initd('stop')
    end

    action :restart do
      initd('restart')
    end

    action :reload do
      initd('reload')
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
  end
end
