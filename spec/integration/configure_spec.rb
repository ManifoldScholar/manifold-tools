RSpec.describe "`manifold-tools configure` command", type: :cli do
  it "executes `manifold-tools help configure` command successfully" do
    output = `manifold-tools help configure`
    expected_output = <<-OUT
Usage:
  manifold-tools configure

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
