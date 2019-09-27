require 'manifold/tools/commands/config'

RSpec.describe Manifold::Tools::Commands::Config do
  it "executes `config` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Config.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
