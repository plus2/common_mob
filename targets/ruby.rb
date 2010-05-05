class Block < AngryMob::Target
  def run
    log "calling block..."
    instance_eval &default_object
  end

  protected

  def default_object
    args.default_object
  end
end
