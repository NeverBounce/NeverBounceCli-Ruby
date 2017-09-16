
module NeverBounce; module CLI; module Script; module Feature
  describe UsesPagination do
    let(:klass) do
      feature = described_class
      Class.new(Meaningful) do
        feature.load(self)
      end
    end

    it "generally works" do
      r = klass.new(env: {
        "PAGE" => "12",
        "PER_PAGE" => "34",
      })
      expect(r.envar_text).to eq "- PAGE     - Fetch page number N ([1], 5)\n- PER_PAGE - Paginate results N items per page (10, [1000])"
      expect(r.page).to eq 12
      expect(r.per_page).to eq 34
    end
  end
end; end; end; end
