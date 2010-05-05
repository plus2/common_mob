require 'common_mob'
require 'etc'
require 'fileutils'

module FileHelpers
  include CommonMob::DigestHelper
  include CommonMob::ShellHelper
  include CommonMob::PatchHelper
  include CommonMob::FileHelper
  include CommonMob::Erb

  def set_file_ownership
    args.owner ||= args.user
    args.group ||= args.user

    unless args.owner.blank? && args.group.blank?
      owner = args.owner || stat.uid
      group = args.group || stat.gid

      owner = Etc.getpwnam(owner.to_s).uid unless Integer === owner
      group = Etc.getgrnam(group.to_s).gid unless Integer === group

      log "setting #{default_object} to owner=#{owner} group=#{group}"
      chown(owner,group)
    end

    unless args.mode.blank?
      log "setting #{default_object} to mode=0%o" % args.mode
      chmod(args.mode) 
    end
  end
end


class DirTarget < AngryMob::Target
  nickname 'dir'

  include FileHelpers
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

class FileTarget < AngryMob::Target
  nickname 'file'
  include FileHelpers

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

  protected

  def default_object
    Pathname(super)
  end

  def state
    {
      :sha512 => sha512(default_object)
    }
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

class Symlink < AngryMob::Target
  include FileHelpers

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


class Template < AngryMob::Target
  include FileHelpers

  def create
    new_content = render_erb(src,variables)

    if sha512(new_content) != before_state[:sha512]
      log "template has changed, overwriting"

      backup_file(default_object)

      default_object.open('w') {|f| f << new_content}
    end

    set_file_ownership
  end

  protected

  def default_object
    Pathname(super)
  end

  def src
    resource(args.src)
  end

  def variables
    (args.variables || {}).update(:node => node)
  end

  def state
    {
      :sha512 => sha512(default_object)
    }
  end

  def validate!
    super
    problem!(":src #{src} doesn't exist" ) unless src.exist?
    problem!(":src #{src} isn't a file"  ) unless src.file?
    problem!(":src #{src} isn't readable") unless src.readable?
  end
end

class Patch < AngryMob::Target
  include FileHelpers
  def patch
    log "patchhing"
    patched = patch_file(default_object)

    if before_state[:sha512] != sha512(patched)
      log "patch has changed, overwriting"

      backup_file(default_object)
      default_object.open('w') {|f| f << patched}
    end
  end

  def unpatch
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
end
