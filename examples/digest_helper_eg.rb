require 'exemplor'
require 'common_mob'


eg.helpers do
  include CommonMob::DigestHelper
  def log(*msg); puts *msg end
  def args
    return @args if @args
    @args = AngryHash.new
  end
end

eg 'htpasswd' do
  generate_htpasswd('foobar')
end
