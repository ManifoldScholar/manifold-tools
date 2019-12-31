require 'manifold/tools/commands/clean'

RSpec.describe Manifold::Tools::Commands::Clean do
  it "executes `clean` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Clean.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
