require 'rubygems'
require 'pathname'
require 'exemplor'
require 'angry_hash'

root = Pathname(__FILE__).dirname.parent

$LOAD_PATH << root+'examples'
$LOAD_PATH << root+'lib'
$LOAD_PATH << root+'../angry_mob/lib'

require 'angry_mob'
require 'common_mob'

mob = root+'mob'
$LOAD_PATH << mob
Pathname.glob(mob+'**/*.rb').each {|p| require p}
