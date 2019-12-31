RSpec.describe "`manifold-tools test` command", type: :cli do
  it "executes `manifold-tools help test` command successfully" do
    output = `manifold-tools help test`
    expected_output = <<-OUT
Usage:
  manifold-tools test PLATFORM VERSION

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
