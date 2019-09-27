RSpec.describe "`manifold-tools build` command", type: :cli do
  it "executes `manifold-tools help build` command successfully" do
    output = `manifold-tools help build`
    expected_output = <<-OUT
Usage:
  manifold-tools build

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
