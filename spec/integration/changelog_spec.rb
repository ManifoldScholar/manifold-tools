RSpec.describe "`manifold-tools changelog` command", type: :cli do
  it "executes `manifold-tools help changelog` command successfully" do
    output = `manifold-tools help changelog`
    expected_output = <<-OUT
Usage:
  manifold-tools changelog

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
