__END__
class UpstartConfig < ::Template
  default_action
  def create
    super
  end

  protected
  def changed
    puts "upstart config changed"
  end

  def before_call
    @default_object = Pathname("/etc/init") + "#{args.default_object}.conf"
    @before_state = state
  end
end
