require 'common_mob'
require 'fileutils'

class DirTarget < AngryMob::Target
  nickname 'dir'
  include CommonMob::FileHelper

  default_action
  def create
    begin
      dir.mkpath unless dir.exist?
      set_file_ownership
    rescue Errno::EEXIST
      # its ok if it already exists *ulp*
    end

    clean if args.clean?
  end


  def delete
    FileUtils.rm_rf(default_object) if dir.exist?
  end


  def clean
    Pathname.glob(default_object + '*').each {|path|
      FileUtils.rm_rf(path)
    }
  end


  protected

  def state
    {
      :exists => dir.exist?
    }
  end


  def default_object
    Pathname(super)
  end

  alias_method :dir, :default_object


  def validate!
  end
end
