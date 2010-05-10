
eg.setup do
  @args = AngryHash.new
  @file = CommonMob::File.new(@args)
end

eg 'creates from string' do
  @file.create
end
