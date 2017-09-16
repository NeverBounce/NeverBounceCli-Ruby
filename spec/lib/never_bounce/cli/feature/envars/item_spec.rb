
describe NeverBounce::CLI::Feature::Envars::Item do
  it "has defaults" do
    r = described_class.new
    expect(r.examples).to eq []
    expect(r.default).to be nil
    expect(r.is_mandatory).to be false
  end
end
