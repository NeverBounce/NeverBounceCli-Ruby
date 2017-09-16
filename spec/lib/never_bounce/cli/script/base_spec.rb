
describe NeverBounce::CLI::Script::Base do
  include_dir_context __dir__

  it_behaves_like "instantiatable"

  describe ".env_value_truthy?" do
    it "generally works" do
      [
        ["", false],
        [" ", false],
        [0, false],
        ["0", false],
        ["kk", false],
        ["n", false],
        ["N", false],

        [1, true],
        ["1", true],
        ["y", true],
        ["Y", true],
        ["yes", true],
        ["YES", true],
        ["true", true],
      ].each do |input, expected|
        expect([input, described_class.env_value_truthy?(input)]).to eq [input, expected]
      end
    end
  end

  describe "#env_truthy?" do
    it "generally works" do
      r = newo(env: {
        # Load a few values, not necessarily every possible one.
        "na" => "",
        "nb" => "0",
        "nc" => "n",
        "ya" => "1",
        "yb" => "y",
        "yc" => "yes",
      })

      [
        ["na", false],
        ["nb", false],
        ["nc", false],
        ["ya", true],
        [:ya, true],
        ["yb", true],
        ["yc", true],
      ].each do |k, expected|
        expect([k, r.env_truthy?(k)]).to eq [k, expected]
      end
    end
  end
end
