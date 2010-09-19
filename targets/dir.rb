require 'common_mob'

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
  end

  def delete
    FileUtils.rm_rf(default_object) if exist?
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
