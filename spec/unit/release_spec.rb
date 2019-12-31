require 'manifold/tools/commands/build'

RSpec.describe Manifold::Tools::Commands::Release do
  it "executes `release` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Release.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
