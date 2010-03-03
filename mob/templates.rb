targets('common-templates') do
  require 'common_mob'

  TargetHelpers do
    include CommonMob::DigestHelper
  end

end
