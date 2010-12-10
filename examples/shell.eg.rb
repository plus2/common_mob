require 'eg_helper'

eg.helpers do
  include CommonMob::ShellHelper
end

eg 'shelly' do
  cmd = "echo hello; echo mars >&2; echo world"
  Show( sh(cmd                                                ).execute )
  Show( sh(cmd, :prefix => "[OXX]"                            ).execute )                       
  Show( sh(cmd, :prefix => {:err => "[OXX]", :out => "[MXX]"} ).execute )
end
