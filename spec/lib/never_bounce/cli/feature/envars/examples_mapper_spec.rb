
describe NeverBounce::CLI::Feature::Envars::ExamplesMapper do
  def m(input)
    described_class.new.process(input)
  end

  it "generally works" do
    # Bad input.
    [
      [[1, abc: "xyz"], ArgumentError, "Unknown element format: {:abc=>\"xyz\"}"],
    ].each do |input, error, message|
      expect {m(input)}.to raise_error(error, message)
    end

    # Good input.
    [
      [[], {values: []}],
      [[1], {values: [1]}],
      [["y", default: "N"], {values: ["y", "N"], default: "N"}],
      [[1, default: 2], {values: [1, 2], default: 2}],
      [[1, {default: 2}, {default: 3}], {values: [1, 2, 3], default: 3}],
    ].each do |input, expected|
      expect([input, m(input)]).to eq([input, expected])
    end
  end
end
