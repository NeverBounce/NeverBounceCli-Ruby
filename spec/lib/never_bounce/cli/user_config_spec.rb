
module NeverBounce::CLI
  describe UserConfig do
    include_dir_context __dir__

    it "generally works" do
      r = newo(fc: described_class::FileContent.new(body:"---\napi_key: abc\napi_url: def"))
      expect(r.api_key).to eq "abc"
      expect(r.api_url).to eq "def"
    end
  end
end
