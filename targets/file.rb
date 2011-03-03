require 'common_mob'

class FileTarget < AngryMob::Target
  nickname 'file'
  include CommonMob::FileHelper

  default_action
  def create
    if args.src
      copy_resource resource(args.src)
    elsif args.string
      create_string
    end

    set_file_ownership
  end

  def delete
    if exist?
      log "deleting #{default_object}"
      unlink
    end
  end

  def modify
    set_file_ownership
  end

  protected

  def default_object
    Pathname(super)
  end

  def state
    {
      :sha512 => sha512(default_object)
    }
  end

  def src
    resource(args.src)
  end

  def validate!
    unless action?(:delete, :modify)
      if args.src?
        problem!(":src #{src} doesn't exist" ) unless src.exist?
      elsif !args.src? && !args.string?
        problem!("please specify one of :src or :string")
      end
    end
  end


  def copy_resource(src)
    if sha512(src) != before_state[:sha512]
      log "input string different from file contents, overwriting"
      src.cp_to(default_object)
    end
  end

  def create_string
    if sha512(args.string) != before_state[:sha512]
      log "input string different from file contents, overwriting"
      default_object.open('w') {|f| f << args.string}
    end
  end

end
