require 'manifold/tools/commands/package'

RSpec.describe Manifold::Tools::Commands::PackageOmnibus do
  it "executes `package_omnibus` command successfully" do
    output = StringIO.new
    options = {}
    command = Manifold::Tools::Commands::PackageOmnibus.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
