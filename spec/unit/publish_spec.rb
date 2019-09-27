require 'manifold/tools/commands/publish'

RSpec.describe Manifold::Tools::Commands::Publish do
  it "executes `publish` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Publish.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
