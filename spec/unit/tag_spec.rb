require 'manifold/tools/commands/tag'

RSpec.describe Manifold::Tools::Commands::Tag do
  it "executes `tag` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Tag.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
