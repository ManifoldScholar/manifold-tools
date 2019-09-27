require 'manifold/tools/commands/configure'

RSpec.describe Manifold::Tools::Commands::Configure do
  it "executes `configure` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Configure.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
