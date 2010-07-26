require 'common_mob'
require 'etc'

class Group < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def ensure
    unless before_state[:exists]
      create
    end
  end

  def create
    log "creating #{default_object}"
    sh("groupadd #{default_object}").run
  end

  protected
  def state
    begin
      group = Etc.getgrnam(default_object)
      {
        :exists => true
      }
    rescue ArgumentError
      {
        :exists => false
      }
    end
  end
  
end
