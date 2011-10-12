require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/autorun'

require 'pathname'
require 'angry_hash'

root = Pathname('../..').expand_path(__FILE__)

$LOAD_PATH << root + 'test'
$LOAD_PATH << root + 'lib'
$LOAD_PATH << root + '../angry_mob/lib'

require 'angry_mob'
require 'common_mob'

$LOAD_PATH << root+'targets'


class MockResourceLocator
  attr_accessor :value

  def [](node, name)
    value
  end
end

class MockNode
  def resource_locator
    @resource_locator ||= MockResourceLocator.new
  end
end


class MockRioter
  def ui
    @ui ||= AngryMob::UI.new
  end

  def node
    @node ||= MockNode.new
  end
end


def rioter
  @rioter ||= MockRioter.new
end

def target(klass, *args)
  klass.new(rioter, '<test>', args)
end
