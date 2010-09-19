require 'common_mob'

class Patch < AngryMob::Target
  include CommonMob::FileHelper

  default_action
  def patch
    log "patching"

    patched = patch_file(default_object)

    if before_state[:sha512] != sha512(patched)
      log "patch has changed, overwriting"

      backup_file(default_object)
      default_object.open('w') {|f| f << patched}
    end
  end

  def unpatch
    # TODO implement
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
