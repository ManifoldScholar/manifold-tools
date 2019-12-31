RSpec.describe "`manifold-tools package-omnibus` command", type: :cli do
  it "executes `manifold-tools help package-omnibus` command successfully" do
    output = `manifold-tools help package-omnibus`
    expected_output = <<-OUT
Usage:
  manifold-tools package-omnibus

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
