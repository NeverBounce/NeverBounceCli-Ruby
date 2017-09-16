
module NeverBounce; module CLI; module Script; module Feature
  describe RequiresJobId do
    let(:klass) do
      feature = described_class
      Class.new(Meaningful) do
        feature.load(self)
      end
    end

    it "generally works" do
      r = klass.new(env: {})
      expect(r.envar_text).to eq "- ID - Job ID (\"276816\")"
      expect { r.job_id }.to raise_error Script::UsageError, /use `ID=`/
    end
  end
end; end; end; end
