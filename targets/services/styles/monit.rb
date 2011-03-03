require 'fileutils'
require 'common_mob'

module CommonMob
  module Services
    module Styles
      module Monit
        include CommonMob::ShellHelper

        def enable_service
          return if service_enabled?

          FileUtils.mv( disabled_monit_config, monit_config ) if disabled_monit_config.exist?

          raise "unable to enable monit config" unless monit_config.tapp(:mc).exist?

          reload_monit!
        end

        def service_enabled?
        end

        def remove_service
          FileUtils.mv( monit_config, disabled_monit_config ) if monit_config.exist?
          reload_monit!
        end

        def signal_service(signal,should_raise=false)
          begin
            monit(signal, name).run
          rescue CommonMob::ShellError
            if should_raise
              raise $!
            else
              log "monit #{signal} #{name} failed (but swallowing exception)"
              log "(out=#{$!.result.stdout})"
              log "(err=#{$!.result.stderr})"
            end
          end
        end

        def is_running?
          !! monit('summary').to_s[/Process '#{name}'\s+running/]
        end

        def ensure_running!
          unless is_running?
            raise "#{name} should be running but isn't"
          end
          log "#{name} is running"
        end

        protected
        def monit(cmd,*args)
          sh("/usr/local/bin/monit #{cmd} #{args * ' '}")
        end

        def reload_monit!
          monit('reload').run
        end

        def monit_config
          Pathname("/etc/monit.d/#{name}.rc")
        end

        def disabled_monit_config
          Pathname("/etc/monit.d/#{name}.rc.am-disabled")
        end
      end
    end
  end
end
