RSpec.describe "`manifold-tools tag` command", type: :cli do
  it "executes `manifold-tools help tag` command successfully" do
    output = `manifold-tools help tag`
    expected_output = <<-OUT
Usage:
  manifold-tools tag

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
