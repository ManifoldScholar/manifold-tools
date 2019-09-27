RSpec.describe "`manifold-tools publish` command", type: :cli do
  it "executes `manifold-tools help publish` command successfully" do
    output = `manifold-tools help publish`
    expected_output = <<-OUT
Usage:
  manifold-tools publish

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
