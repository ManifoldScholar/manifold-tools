require 'manifold/tools/commands/publish'

RSpec.describe Manifold::Tools::Commands::Push do
  it "executes `push` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Push.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
