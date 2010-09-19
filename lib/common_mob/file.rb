require 'pathname'
require 'etc'
require 'fileutils'

module CommonMob
  module FileHelper
    def backup_file(f)
      return if FalseClass === args.backup || args.backup == 0

      backups = args.backups || 5
      backups = backups.to_i

      root = f.dirname
      backedup = f.basename.to_s + ".AM-#{Time.now.to_i}"
      backup = root+backedup

      log "backing #{f} up to #{backup}"

      FileUtils.cp f, (backup)

      if backups > 0
        existing_backups = Pathname.glob( root + "#{f.basename}.AM-*" ).sort_by {|f| f.ctime}.reverse
        if existing_backups.size > backups
          log "deleting #{existing_backups.size - backups} old backups (keeping #{backups})"
          existing_backups[backups..-1].each {|to_del| to_del.unlink}
        end
      end

      backup
    rescue Errno::ENOENT
      # *ulp*
    end

    def set_file_attrs(file,owner,group,mode)
      file = Pathname(file)

      unless owner.blank? && group.blank?
        owner ||= file.stat.uid
        group ||= file.stat.gid

        owner = Etc.getpwnam(owner.to_s).uid unless Integer === owner
        group = Etc.getgrnam(group.to_s).gid unless Integer === group

        log "setting #{file} to owner=#{owner} group=#{group}"

        file.chown(owner,group)
      end

      unless mode.blank?
        log "setting #{file} to mode=0%o" % mode
        file.chmod(mode) 
      end
    end
    

    include CommonMob::DigestHelper
    include CommonMob::ShellHelper
    include CommonMob::PatchHelper
    include CommonMob::Template

    def set_file_ownership
      args.owner ||= args.user
      args.group ||= args.user

      set_file_attrs(default_object, args.owner, args.group, args.mode)
    end

  end
end
