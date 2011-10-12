require 'test_helper'
require 'file_target'

describe FileTarget do
  before do
  end

  describe ":src" do
    it "creates a file" do
      rioter.node.resource_locator.value = Pathname("hello.txt") # XXX fixture
      target( FileTarget, "/tmp/foo.txt", :src => "hello" ).call
    end
  end
end

