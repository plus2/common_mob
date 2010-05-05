require 'common_mob'

class Service < AngryMob::SingletonTarget
  include CommonMob::ShellHelper

  default_action
  def enable
    unless before_state[:enabled]
      begin
        sh("/usr/sbin/update-rc.d #{name} defaults").run
      rescue CommonMob::ShellError
        # can't really be expected to enable before init.d exists... maybe should be caught with an if?
        if ! $!.result.stderr[/file does not exist$/]
          raise $!
        end
      end
      log "enabled service #{nickname}"
    end
  end

  def disable
    if before_state[:enabled]
      sh("/usr/sbin/update-rc.d -f #{name} remove").run
      log "disabled service #{nickname}"
    end
  end

  def start
    initd('start')
    ensure_running!
  end

  def stop
    initd('stop')
  end

  def restart
    initd('restart')
    ensure_running!
  end

  def reload
    initd('reload')
    ensure_running!
  end

  protected

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
        log "/etc/init.d/#{name} #{command} failed (but swallowing exception) (err=#{$!.result.stderr})"
      end
    end
  end

  def raise_on_failed_initd?
    false
  end

  def ensure_running!
    ensure_running_with_initd!
  end

  def ensure_running_with_initd!
    unless sh("/etc/init.d/#{name} status").ok?
      raise "#{name} should be running but isn't"
    end
    log "#{name} is running"
  end

  def ensure_running_with_pid!(pidfile)
    pid = pidfile.pathname.read.chomp.to_i
    Process.kill(0,pid)
    true
  rescue Errno::ENOENT
    raise "#{name} not running: no pidfile found at #{pidfile}"
  rescue Errno::ESRCH
    raise "#{name} not running: no process with pid #{pid} found (pidfile at #{pidfile})"
  end

end
