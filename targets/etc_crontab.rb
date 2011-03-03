require 'common_mob'

class EtcCrontab < AngryMob::Target
  default_action
  def create
    if before_state[:changed]
      crontab_file.open('w') {|f| f << new_crontab}
    end
  end

  protected
  def validate!
    if !args.actions.include?('delete')
      problem!("please specify a crontab key as the default_object (etc_crontab('key-something-unique'))") if     default_object.blank?
      problem!("please specify a crontab (:crontab => '* * * * * /bin/echo yay')"                  ) unless args.crontab?
    end
  end

  def state
    {
      :changed => (new_crontab.strip != crontab.strip)
    }
  end

  def crontab_file
    Pathname("/etc/cron.d/plus2-#{default_object}")
  end

  def new_crontab
    @new_crontab ||= new_crontab!
  end

  def new_crontab!
    line = args.crontab.split(/\s+/)
    line.insert(5, user)

    [ crontab_header, line.join(' ') ].join("\n") + "\n"
  end

  def crontab
    crontab_file.exist? ? crontab_file.read : ''
  end

  def user
    args.user || 'root'
  end

  def crontab_header
    "PATH=/bin:/usr/bin:/usr/local/bin:/usr/local/mongodb/bin"
  end
end
