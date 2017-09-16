
module NeverBounce; module CLI; module Script
  describe JobsDelete do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "ID=12"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-delete/, /ID/]

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv)
        expect(r.request_curl).to eq ["--request", "POST", "--url", "https://api.neverbounce.com/v4/jobs/delete", "--header", "Content-Type: application/json", "--data-binary", "{\"job_id\":\"12\",\"key\":\"abc\"}"]
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","execution_time":66}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /Response:/ }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
      end
    end
  end
end; end; end
