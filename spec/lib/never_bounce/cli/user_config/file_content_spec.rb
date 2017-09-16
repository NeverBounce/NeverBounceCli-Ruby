
describe NeverBounce::CLI::UserConfig::FileContent do
  include_dir_context __dir__

  describe "#[]" do
    it "generally works" do
      r = newo(body_hash: {"a" => 1})
      expect(r["a"]).to eq 1
      expect(r[:a]).to eq 1
      expect(r[:b]).to be nil
    end
  end

  describe "#body_hash" do
    it "generally works" do
      r = newo(body: "")
      expect(r.body_hash).to eq({})

      r = newo(body: ":")
      expect { r.body_hash }.to raise_error YAML::SyntaxError

      r = newo(body: "a: 1\nb: 2")
      expect(r.body_hash).to eq({"a" => 1, "b" => 2})
    end
  end

  describe "#filename" do
    it "generally works" do
      r = newo(env: {"HOME" => "/home/joe"})
      expect(r.filename).to eq "/home/joe/.neverbounce.yml"
    end
  end

  describe "#has_key?" do
    it "generally works" do
      r = newo(body_hash: {"a" => 1})
      expect(r.has_key? :a).to be true
      expect(r.has_key? "a").to be true
      expect(r.has_key? :b).to be false
      expect(r.has_key? "b").to be false
    end
  end
end
