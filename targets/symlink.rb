require 'common_mob'

# symlink("from/path", :to => "to/path")
#
class Symlink < AngryMob::Target
  include CommonMob::FileHelper

  default_action
  def create
    if before_state[:points_to] != to
      log "linking #{from} -> #{to}"
      sh("ln -nfs #{to} #{from}").run
    end

    ensure_points_to_correct_file!
  end

  def delete
  end

  protected

  def ensure_points_to_correct_file!
    raise "symlink doesn't point #{from} -> #{to} after action" unless state[:points_to] == to
  end

  def from
    Pathname(default_object).expand_path
  end
  def to
    Pathname(args.to).expand_path.realpath
  end

  def state
    points_to = begin
                  from.readlink
                rescue Errno::ENOENT,Errno::EINVAL
                  nil
                end
    {
      :points_to => points_to
    }
  end

  def validate!
    problem!("file we're linking to doesn't exist") unless to.exist? # is this a real problem?
  end
end

