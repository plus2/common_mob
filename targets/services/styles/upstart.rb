require 'fileutils'
require 'common_mob'

module CommonMob
  module Services
    module Styles
      module Upstart
        include CommonMob::ShellHelper

        def enable_service
          return if service_enabled?

          FileUtils.mv( disabled_upstart_config, upstart_config ) if disabled_upstart_config.exist?

          raise "unable to enable config" unless upstart_config.exist?
        end

        def service_enabled?
          upstart_config.exist?
        end

        def remove_service
          FileUtils.mv( upstart_config, disabled_upstart_config ) if upstart_config.exist?
        end

        def signal_service(signal,should_raise=false)
          begin
            initctl(signal,name).run
          rescue CommonMob::ShellError
            if should_raise
              raise $!
            else
              log "/sbin/initctl #{signal} #{name} failed (but swallowing exception)"
              log "(out=#{$!.result.stdout})"
              log "(err=#{$!.result.stderr})"
            end
          end
        end

        def is_running?
          !! initctl('status', name).to_s[/#{Regexp.escape(name)}.*running/]
        end

        def ensure_running!
          unless is_running?
            raise "#{name} should be running but isn't"
          end
          log "#{name} is running"
        end

        protected
        def initctl(cmd,*args)
          sh("/sbin/initctl #{cmd} #{args * ' '}")
        end

        def upstart_config
          Pathname("/etc/init/#{name}.conf")
        end

        def disabled_upstart_config
          Pathname("/etc/init/#{name}.conf.am-disabled")
        end
      end
    end
  end
end
