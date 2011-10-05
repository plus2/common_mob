require 'common_mob'

class Sh < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def execute
    if ! before_state[:created]
      result = sh(script, opts).execute

      begin
        result.ensure_ok!
      rescue CommonMob::ShellError
        if args.swallow_error?
          log "command failed, but ignoring"
        else
          raise $!
        end
      end

      if ui.debug?
        ui.debug "stdout=#{result.stdout}"
        ui.debug "stderr=#{result.stderr}"
      end

    end
  end


  protected

  alias_method :script, :default_object


  def opts
    opts = AngryHash[ args ]

    opts.delete_all_of(%w{notify action default_object creates})

    opts
  end


  def state
    if args.creates
      {
        :created => args.creates.pathname.exist?
      }
    else # force state changed if we don't have any state comparison to go on
      {
        :rand => rand
      }
    end

  end
end
