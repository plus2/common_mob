module CommonMob
  class Block < AngryMob::Target
    default_action :run do
      log "calling block..."
      instance_eval &default_object
    end

    def default_object
      args.default_object
    end
  end
end
