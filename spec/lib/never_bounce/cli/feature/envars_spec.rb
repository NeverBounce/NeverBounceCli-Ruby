
describe NeverBounce::CLI::Feature::Envars do
  describe "#define_envar" do
    it "generally works" do
      feature = described_class

      parent = Class.new do
        feature.load(self)
        define_envar "p.var1", "p.cmt1"
      end

      r = Class.new(parent) do
        define_envar "var1", "cmt1"
        define_envar "var2", "cmt2", is_mandatory: true
        define_envar "var3", "cmt3", examples: ["a", "b"]
        define_envar "var4", "cmt4", examples: ["y", "N"], default: "N"
      end.new

      # Do some "matrix" checks on the items.
      envars = r.class.envars
      expect(envars.size).to eq 5
      expect(envars.map(&:name)).to eq ["p.var1", "var1", "var2", "var3", "var4"]
      expect(envars.map(&:comment)).to eq ["p.cmt1", "cmt1", "cmt2", "cmt3", "cmt4"]
      expect(envars.map(&:is_mandatory)).to eq [false, false, true, false, false]
      expect(envars.map(&:examples)).to eq [[], [], [], ["a", "b"], ["y", "N"]]
      expect(envars.map(&:default)).to eq [nil, nil, nil, nil, "N"]
    end
  end

  describe "#envar" do
    it "generally works" do
      feature = described_class

      parent = Class.new do
        feature.load(self)
        envar "p.var1", "p.cmt1"
      end

      r = Class.new(parent) do
        envar "var1", "cmt1"
        envar "var2*", "cmt2"
        envar "var3", "cmt3", ["a", "b"]
        envar "var4", "cmt4", ["y", default: "N"]
      end.new

      envars = r.class.envars
      expect(envars.size).to eq 5
      expect(envars.map(&:name)).to eq ["p.var1", "var1", "var2", "var3", "var4"]
      expect(envars.map(&:comment)).to eq ["p.cmt1", "cmt1", "cmt2", "cmt3", "cmt4"]
      expect(envars.map(&:is_mandatory)).to eq [false, false, true, false, false]
      expect(envars.map(&:examples)).to eq [[], [], [], ["a", "b"], ["y", "N"]]
      expect(envars.map(&:default)).to eq [nil, nil, nil, nil, "N"]
    end
  end
end
