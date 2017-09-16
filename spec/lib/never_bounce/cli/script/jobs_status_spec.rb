
module NeverBounce; module CLI; module Script
  describe JobsStatus do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "ID=12"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-status/]

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv)
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4/jobs/status", "--header", "Content-Type: application/json", "--data-binary", "{\"job_id\":\"12\",\"key\":\"abc\"}"]
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","id":274226,"job_status":"complete","filename":"Created from Array.csv","created_at":"2017-07-21 17:33:45","started_at":"2017-07-21 17:33:46","finished_at":"2017-07-21 17:33:47","total":{"records":3,"billable":2,"processed":3,"valid":1,"invalid":2,"catchall":0,"disposable":0,"unknown":0,"duplicates":0,"bad_syntax":1},"bounce_estimate":0,"percent_complete":100,"execution_time":7}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /^Response:$/ }
        expect(lines).to be_any { |s| s =~ cell("ID") }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
        expect(lines).to be_any { |s| s =~ /^Total:$/ }
        expect(lines).to be_any { |s| s =~ cell("BadSyntax") }
        expect(lines).to be_any { |s| s =~ cell("Valid") }
      end
    end
  end
end; end; end
