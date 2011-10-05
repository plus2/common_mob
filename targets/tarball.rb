require 'common_mob'

class Tarball < AngryMob::Target
  include CommonMob::ShellHelper

  default_action
  def extract
    cmd = "tar #{compression_opt}xf #{tarball}"

    if !dest.blank?
      sh("#{cmd} --strip 1 -C #{dest}").run
    else
      sh("#{cmd}").run
    end
  end


  protected


  def tarball; default_object end


  def compression_opt
    ext = tarball.to_s[/\.([^\.]+)$/,1].downcase
    case ext
    when 'gz'
      'z'
    when 'bz2'
      'j'
    end
  end


  def dest
    args.dest || args.extract_to || args.to
  end


  # no really good way to tell if we need to untar again...
  def state
    {
      :rand => rand
    }
  end
end
