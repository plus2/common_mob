require 'pathname'
root = Pathname('../../').expand_path(__FILE__)
$LOAD_PATH << root+'vendor/mustache/lib'

module CommonMob
  autoload :FileHelper   , 'common_mob/file'
  autoload :PatchHelper  , 'common_mob/patch'
  autoload :DigestHelper , 'common_mob/digest'
  autoload :Template     , 'common_mob/template'
  autoload :ShellHelper  , 'common_mob/shell'
  autoload :ProcessHelper, 'common_mob/process'
end
