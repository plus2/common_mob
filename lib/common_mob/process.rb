module CommonMob
  module ProcessHelper
    def self.ensure_pid(pidfile_or_pid)
      pid = pidfile_or_pid.to_i
      pidfile = nil

      if pid != 0
        pid = pidfile_or_pid.pathname.read.chomp.to_i
        pidfile = pidfile_or_pid
      end

      Process.kill(0,pid)
      true
    rescue Errno::ENOENT
      raise "#{name} not running: no pidfile found at #{pidfile}"
    rescue Errno::ESRCH
      raise "#{name} not running: no process with pid #{pid} found #{"(pidfile at #{pidfile})" if pidfile}"
    end
  end
end
