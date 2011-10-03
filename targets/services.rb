require 'common_mob'




class Service < AngryMob::Target
  include CommonMob::ShellHelper


  class << self
    def instance_key(args)
      "service:#{nickname}"
    end


    def sysv_service
      include CommonMob::Services::Styles::Sysv
    end


    def pid_service
      include CommonMob::Services::Styles::Pid
    end


    def debian_service
      include CommonMob::Services::Styles::Debian
    end


    def upstart_service
      include CommonMob::Services::Styles::Upstart
    end


    def redhat_service
      include CommonMob::Services::Styles::Redhat
    end


    def monit_service
      include CommonMob::Services::Styles::Monit
    end
  end


  default_action
  def enable
    unless before_state[:enabled]
      enable_service
      log "enabled service #{nickname}"
    end
  end


  def disable
    if before_state[:enabled]
      remove_service
      log "disabled service #{nickname}"
    end
  end


  def start
    signal_service('start')
    ensure_running!
  end


  def stop
    signal_service('stop')
  end


  def restart
    if is_running?
      ui.log "restarting."
      signal_service('restart', true)
    else
      ui.log "restart requested, but not running: starting."
      signal_service('start')
    end

    ensure_running!
  end


  def reload
    if is_running?
      ui.log "reloading."
      signal_service('reload', true)
    else
      ui.log "reload requested, but not running: starting."
      signal_service('start')
    end

    ensure_running!
  end


  def be_running
    start
  end


  def to_s
    "#{nickname}()"
  end


  def self.at_least_lucid?
    issue = "/etc/issue".pathname
    issue.exist? && issue.read[/ubuntu.+10\.04/i]
  end


  def at_least_lucid?
    self.class.at_least_lucid?
  end
  

  protected
  def validate!
  end


  def state
    {
      :enabled => service_enabled?
    }
  end


  def name
    nickname
  end


  def self.service_name(name)
    self.class_eval "def name; '#{name}' end"
  end
end
