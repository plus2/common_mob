module CommonMob
  module Services
    module Styles
      module Pid

        def ensure_running!
          # TODO replace with CommonMob::ProcessHelper.find_pid()

          pid = pidfile.pathname.read.chomp.to_i
          Process.kill(0,pid)
          true
        rescue Errno::ENOENT
          raise "#{name} not running: no pidfile found at #{pidfile}"
        rescue Errno::ESRCH
          raise "#{name} not running: no process with pid #{pid} found (pidfile at #{pidfile})"
        end

        def is_running?
          pid = pidfile.pathname.read.chomp.to_i
          Process.kill(0,pid)
          true
        rescue Errno::ENOENT,Errno::ESRCH
          false
        end
      end
    end
  end
end
