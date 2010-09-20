class MonitConfig < Template
  default_action
  def create
    super
  end

  protected
  def changed
    puts "monit config changed!"
    args.fire = 'monit/restart'
  end

  def before_call
    @default_object = Pathname("/etc/monit.d") + "#{args.default_object}.rc"
    default_object.tapp(:monit_config)
    
    @before_state = state
  end

end
