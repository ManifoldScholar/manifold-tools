RSpec.describe "`manifold-tools release` command", type: :cli do
  it "executes `manifold-tools help release` command successfully" do
    output = `manifold-tools help release`
    expected_output = <<-OUT
Usage:
  manifold-tools release

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
