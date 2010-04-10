require 'exemplor'
require 'common_mob'
require 'angry_hash'
require 'pp'

class Object
  def tapp(tag=nil)
    print "#{tag}: " if tag
    pp self
    self
  end
end

eg.helpers do
  include CommonMob::PatchHelper
  def args
    return @args if @args
    @args = AngryHash.new
  end
end

eg 'patches twice' do
  args.key = 'foobar'
  args.string = 'boofat'

  to_patch = StringIO.new("hello dolly")

  next_string = patch_file(to_patch)

  args.string = 'cowfat'

Check( patch_file(StringIO.new(next_string)) ).is(%{hello dolly
# angry-mob foobar start
cowfat
# angry-mob foobar end

})
end
