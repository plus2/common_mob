require 'common_mob'

module CommonMob
  module Services
    module Styles
      module Debian
        include CommonMob::ShellHelper

        def enable_service
          sh("/usr/sbin/update-rc.d #{name} defaults").run
        end

        def service_enabled?
          sh("/usr/sbin/update-rc.d -n -f #{name} remove").to_s[%r[/etc/rc\d+.d/]]
        end

        def remove_service
          sh("/usr/sbin/update-rc.d -f #{name} remove").run
        end
      end
    end
  end
end
