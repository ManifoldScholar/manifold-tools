require 'manifold/tools/commands/build'

RSpec.describe Manifold::Tools::Commands::Build do
  it "executes `build` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Build.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
