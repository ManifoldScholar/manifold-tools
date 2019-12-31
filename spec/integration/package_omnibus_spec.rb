RSpec.describe "`manifold-tools package_omnibus` command", type: :cli do
  it "executes `manifold-tools help package_omnibus` command successfully" do
    output = `manifold-tools help package_omnibus`
    expected_output = <<-OUT
Usage:
  manifold-tools package_omnibus

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
