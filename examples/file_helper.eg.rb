require 'exemplor'
require 'common_mob'
require 'angry_hash'
require 'pp'
require 'fileutils'

class Object
  def tapp(tag=nil)
    print "#{tag}: " if tag
    pp self
    self
  end
end

eg.helpers do
  include CommonMob::FileHelper
  def log(*msg); puts *msg end
  def args
    return @args if @args
    @args = AngryHash.new
  end
end

eg.setup do
  system("rm /tmp/am_file_helper.tmp*")
end

eg 'thins backups' do
  args.backups = '2'

  f = Pathname("/tmp/am_file_helper.tmp")
  FileUtils.touch(f)

  backup_file(f)
  sleep(1)
  backup_file(f)
  sleep(1)
  b1 = backup_file(f)
  sleep(1)

  b2 = backup_file(f)

  files = Pathname.glob("/tmp/am_file_helper.tmp*")
  Check( files.size ).is(3)
  Check( files[0] ).is(f)
  Check( files[1] ).is(b1)
  Check( files[2] ).is(b2)
end

# eg 'no backup' do
# end
# eg 'no limit to backups' do
# end
