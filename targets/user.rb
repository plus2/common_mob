require 'common_mob'
require 'etc'

class User < AngryMob::Target
  include CommonMob::ShellHelper

  def ensure
    if before_state[:exists] then update else create end
  end

  def create
    opt_string = opts

    unless opt_string.blank?
      log "creating #{default_object}"
      sh("useradd #{opts} #{default_object}").run
    end
  end

  def update
    opt_string = opts

    unless opt_string.blank?
      log "updating #{default_object}"
      sh("usermod #{opts} #{default_object}").run
    end
  end

  def delete
  end

  def lock
  end

  def unlock
  end

  protected

  def state
    begin
      user = Etc.getpwnam(default_object)

      groups = []

      username = default_object
      Etc.group do |g|
        groups << g.name if g.mem.include?(username)
      end

      extra_groups = groups.uniq - [ Etc.getgrgid(user.gid).name ]

      {
        :exists  => true,
        :uid     => user.uid,
        :gid     => user.gid,
        :comment => user.gecos,
        :home    => user.dir,
        :shell   => user.shell,
        :extra_groups => extra_groups
      }
    rescue ArgumentError => e
      {
        :exists => false
      }
    end
  end


  def default_object
    super.to_s
  end

  def validate!
    super
    problem!("username is blank") if default_object.blank?
  end

  protected
  def opts
    opts = ''
    switches = {
      :comment => '-c',
      :gid     => '-g',
      :uid     => '-u',
      :shell   => '-s',
      :set_home => lambda {|value| "-d '#{value}'"   },
      :home     => lambda {|value| "-d '#{value}' -m"},
      :extra_groups => lambda {|value| "-G #{value * ','}"}
    }

    switches.each do |(key,switch)|
      to_value = args.__send__(key)

    if !to_value.nil? && to_value != before_state[key]
      if switch.respond_to?(:call)
        opts << switch.call(to_value)
      else
        opts << " #{switch} '#{to_value}'"
      end
      opts << ' '
    end
    end

    opts
  end
end
