require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ghostjour/cli'

describe Ghostjour::CLI, "execute" do
  before(:each) do
    @stdout_io = StringIO.new
    Ghostjour::CLI.execute(@stdout_io, [])
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  it "should do something" do
    @stdout.should_not =~ /To update this executable/
  end
end