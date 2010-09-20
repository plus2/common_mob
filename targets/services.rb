require 'common_mob'

class Service < AngryMob::Target
  include CommonMob::ShellHelper

  def self.instance_key(args)
    "service:#{nickname}"
  end

	# TODO add service style mixins
	#include CommonMob::Service::Styles::Sysv
	#include CommonMob::Service::Styles::Debian
	#include CommonMob::Service::Styles::Upstart
	#include CommonMob::Service::Styles::Redhat

  default_action
  def enable
    unless before_state[:enabled]
      begin
        sh("/usr/sbin/update-rc.d #{name} defaults").run
      rescue CommonMob::ShellError
        # can't really be expected to enable before init.d exists
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
    if is_running?
      ui.log "restarting."
      initd('restart', true)
    else
      ui.log "restart requested, but not running: starting."
      initd('start')
    end

    ensure_running!
  end

  def reload
    if is_running?
      ui.log "reloading."
      initd('reload', true)
    else
      ui.log "reload requested, but not running: starting."
      initd('start')
    end

    ensure_running!
  end

  def be_running
    start
  end


  def to_s
    "#{nickname}()"
  end

  protected
  def validate!
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

  def self.service_name(name)
    self.class_eval "def name; '#{name}' end"
  end

  def initd(command,should_raise=false)
    should_raise = raise_on_failed_initd?
    begin
      sh("/etc/init.d/#{name} #{command}").run
    rescue CommonMob::ShellError
      if should_raise
        raise $!
      else
        log "/etc/init.d/#{name} #{command} failed (but swallowing exception)"
        log "(out=#{$!.result.stdout})"
        log "(err=#{$!.result.stderr})"
      end
    end
  end


  def raise_on_failed_initd?
    false
  end

  def self.pidfile(pidfile)
    self.class_eval %{
      def pidfile; "#{pidfile}" end
      def process_approach; :pid end
    }
  end

  def process_approach
    :initd
  end

  def pidfile
    raise "Not implemented. To use the pid based process approach, please override pidfile in #{self.class}."
  end

  def ensure_running!
    case process_approach
    when :initd
      ensure_running_with_initd!
    when :pid
      ensure_running_with_pid!
    else
      raise ArgumentError, "Unknown process_approach '#{process_approach}'\nSet the process approach to :initd or :pid\ndef process_approach\n\t:initd\nend"
    end
  end

  def is_running?
    case process_approach
    when :initd
      is_running_initd?
    when :pid
      is_running_pid?
    else
      raise ArgumentError, "Unknown process_approach '#{process_approach}'\nSet the process approach to :initd or :pid\ndef process_approach\n\t:initd\nend"
    end
  end

  def is_running_initd?
    sh("/etc/init.d/#{name} status").ok?
  end

  def is_running_pid?
    pid = pidfile.pathname.read.chomp.to_i
    Process.kill(0,pid)
    true
  rescue Errno::ENOENT,Errno::ESRCH
    false
  end

  def ensure_running_with_initd!
    unless sh("/etc/init.d/#{name} status").ok?
      raise "#{name} should be running but isn't"
    end
    log "#{name} is running"
  end

  def ensure_running_with_pid!
    # TODO replace with CommonMob::ProcessHelper.find_pid()
    pid = pidfile.pathname.read.chomp.to_i
    Process.kill(0,pid)
    true
  rescue Errno::ENOENT
    raise "#{name} not running: no pidfile found at #{pidfile}"
  rescue Errno::ESRCH
    raise "#{name} not running: no process with pid #{pid} found (pidfile at #{pidfile})"
  end

  def at_least_lucid?
    issue = "/etc/issue".pathname
    issue.exist? && issue.read[/ubuntu.+10\.04/i]
  end
end
