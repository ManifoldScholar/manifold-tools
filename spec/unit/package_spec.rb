require 'manifold/tools/commands/package'

RSpec.describe Manifold::Tools::Commands::Package do
  it "executes `package` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Package.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
