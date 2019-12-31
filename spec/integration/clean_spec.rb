RSpec.describe "`manifold-tools clean` command", type: :cli do
  it "executes `manifold-tools help clean` command successfully" do
    output = `manifold-tools help clean`
    expected_output = <<-OUT
Usage:
  manifold-tools clean

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
