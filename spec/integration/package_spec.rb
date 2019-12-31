RSpec.describe "`manifold-tools package` command", type: :cli do
  it "executes `manifold-tools help package` command successfully" do
    output = `manifold-tools help package`
    expected_output = <<-OUT
Usage:
  manifold-tools package

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
