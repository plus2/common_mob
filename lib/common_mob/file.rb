
module CommonMob
  module FileHelper
    def backup_file(f)
      return if FalseClass === args.backup || args.backup == 0

      backups = args.backups.to_i || 5

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
  end
end
