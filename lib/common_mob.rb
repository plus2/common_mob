require 'pathname'
root = Pathname('../../').expand_path(__FILE__)
$LOAD_PATH << root+'vendor/mustache/lib'

require 'common_mob/file'
require 'common_mob/patch'
require 'common_mob/digest'
require 'common_mob/template'
require 'common_mob/shell'
