require 'manifold/tools/commands/test'

RSpec.describe Manifold::Tools::Commands::Test do
  it "executes `test` command successfully" do
    output = StringIO.new
    platform = nil
    version = nil
    options = {}
    command = Manifold::Tools::Commands::Test.new(platform, version, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
