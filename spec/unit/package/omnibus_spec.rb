require 'manifold/tools/commands/package/omnibus'

RSpec.describe Manifold::Tools::Commands::Package::Omnibus do
  it "executes `package-omnibus` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::Package::Omnibus.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
