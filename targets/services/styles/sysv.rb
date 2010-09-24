require 'common_mob'

module CommonMob
  module Services
    module Styles
      module Sysv
        include CommonMob::ShellHelper

        def signal_service(signal,should_raise=false)
          begin
            sh("/etc/init.d/#{name} #{signal}").run
          rescue CommonMob::ShellError
            if should_raise
              raise $!
            else
              log "/etc/init.d/#{name} #{signal} failed (but swallowing exception)"
              log "(out=#{$!.result.stdout})"
              log "(err=#{$!.result.stderr})"
            end
          end
        end

        def is_running?
          sh("/etc/init.d/#{name} status").ok?
        end

        def ensure_running!
          unless sh("/etc/init.d/#{name} status").ok?
            raise "#{name} should be running but isn't"
          end
          log "#{name} is running"
        end
      end
    end
  end
end
