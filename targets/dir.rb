require 'common_mob'
require 'fileutils'

class DirTarget < AngryMob::Target
  nickname 'dir'
  include CommonMob::FileHelper

  default_action
  def create
    begin
      mkpath unless exist?
      set_file_ownership
    rescue Errno::EEXIST
      # *ulp*
    end

    clean if args.clean?
  end

  def delete
    FileUtils.rm_rf(default_object) if exist?
  end

  def clean
    Pathname.glob(default_object + '*').each {|path|
      FileUtils.rm_rf(path)
    }
  end

  protected

  def state
    {
      :exists => exist?
    }
  end

  def default_object
    Pathname(super)
  end

  def validate!
  end
end
