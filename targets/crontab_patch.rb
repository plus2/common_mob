require 'common_mob'

class Crontab < AngryMob::Target
  include CommonMob::ShellHelper
  include CommonMob::PatchHelper

  default_action
  def patch
    if before_state[:changed]
      sh("crontab -u #{user} -", :input => new_crontab).run
    end
  end

  def validate!
    problem!("please specify a patch key as the default_object (crontab('key-something-unique'))") if     default_object.blank?
    problem!("please specify a crontab (:crontab => '* * * * * /bin/echo yay')"                  ) unless args.crontab?
  end

  def state
    {
      :changed => (new_crontab != crontab)
    }
  end

  protected
  def new_crontab
    @new_crontab ||= patch_string(crontab, args.crontab, :key => default_object)
  end

  def crontab
    sh("crontab -l -u #{user}").to_s
  end

  def user
    args.user || 'root'
  end
end
