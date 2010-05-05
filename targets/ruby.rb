class Block < AngryMob::Target
  default_action
  def run
    log "calling block..."
    instance_eval &default_object
  end

  protected

  def default_object
    args.default_object
  end
end
