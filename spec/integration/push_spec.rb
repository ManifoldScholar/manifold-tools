RSpec.describe "`manifold-tools push` command", type: :cli do
  it "executes `manifold-tools help push` command successfully" do
    output = `manifold-tools help push`
    expected_output = <<-OUT
Usage:
  manifold-tools push

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
