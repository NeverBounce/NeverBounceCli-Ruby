
module NeverBounce; module CLI; module Script
  describe RequestMaker do
    include_dir_context __dir__

    it_behaves_like "instantiatable"

    describe "envars" do
      it "generally works" do
        envars = described_class.envars
        expect(envars.map(&:name)).to eq ["API_KEY", "API_URL", "CURL", "RAW"]
        expect(envars.map(&:mandatory?)).to eq [true, false, false, false]
      end
    end

    describe "CURL=y" do
      it "generally works" do
        r = goodo(
          argv: ["CURL=y"],
          request: API::Request::JobsParse.new(api_key: "api_key", job_id: "job_id"),
        )
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines[0]).to start_with "curl --request POST --url https://api.neverbounce.com/v4.1/jobs/parse"
      end
    end

    describe "RAW=y" do
      it "generally works" do
        r = goodo(
          argv: ["RAW=y"],
          server_raw: "raw123",
        )
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to eq ["raw123\n"]
      end
    end

    describe "#api_key" do
      it "generally works" do
        r = newo(env: {}, user_config: Struct.new(:api_key).new)
        expect { r.api_key }.to raise_error(UsageError, "API key not given, use `API_KEY=`")
        r = newo(env: {"API_KEY" => "api_key"})
        expect(r.api_key).to eq "api_key"
        r = newo(env: {}, user_config: Class.new { def api_key; "api_key2"; end }.new)
        expect(r.api_key).to eq "api_key2"
      end
    end

    describe "#api_url" do
      it "generally works" do
        r = newo(env: {}, user_config: Struct.new(:api_url).new)
        expect(r.api_url).to be nil
        r = newo(env: {"API_URL" => "api_url"})
        expect(r.api_url).to eq "api_url"
        r = newo(env: {}, user_config: Class.new { def api_url; "api_url2"; end }.new)
        expect(r.api_url).to eq "api_url2"
      end
    end
  end
end; end; end

#
# Implementation notes:
#
# * We check envars in order of declaration for ease of whole-set testing.
