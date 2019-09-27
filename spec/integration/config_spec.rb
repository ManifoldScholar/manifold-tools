RSpec.describe "`manifold-tools config` command", type: :cli do
  it "executes `manifold-tools help config` command successfully" do
    output = `manifold-tools help config`
    expected_output = <<-OUT
Usage:
  manifold-tools config

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
