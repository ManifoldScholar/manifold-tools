require 'manifold/tools/commands/changelog'

RSpec.describe Manifold::Tools::Commands::Changelog do
  it "executes `changelog` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Changelog.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
