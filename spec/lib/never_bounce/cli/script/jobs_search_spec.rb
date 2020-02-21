
module NeverBounce; module CLI; module Script
  describe JobsSearch do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-search/, /PAGE/]

    describe "mode attributes" do
      describe "#job_id" do
        let(:m) { :job_id }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect(newo(env: {"ID" => "abc"}).send(m)).to eq "abc"
          expect(newo(env: {"ID" => "12"}).send(m)).to eq "12"
        end
      end
    end

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv(
          "ID=abc",
          "PAGE=12",
          "PER_PAGE=34",
        ))
        expect(r.job_id).to eq "abc"
        expect(r.page).to eq 12
        expect(r.per_page).to eq 34
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4.1/jobs/search", "--header", "Content-Type: application/json", "--data-binary", "{\"key\":\"abc\",\"job_id\":\"abc\",\"page\":12,\"items_per_page\":34}"]
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","total_results":5,"total_pages":1,"query":{"page":1,"items_per_page":1000},"results":[{"id":276816,"job_status":"failed","filename":"","created_at":"2017-07-25 09:04:10","started_at":null,"finished_at":null,"total":{"records":0,"billable":0,"processed":null,"valid":null,"invalid":0,"catchall":null,"disposable":null,"unknown":null,"duplicates":null,"bad_syntax":null},"bounce_estimate":-1,"percent_complete":0},{"id":276760,"job_status":"failed","filename":"","created_at":"2017-07-25 08:31:16","started_at":null,"finished_at":null,"total":{"records":0,"billable":0,"processed":null,"valid":null,"invalid":0,"catchall":null,"disposable":null,"unknown":null,"duplicates":null,"bad_syntax":null},"bounce_estimate":-1,"percent_complete":0},{"id":276743,"job_status":"queued","filename":"","created_at":"2017-07-25 08:06:38","started_at":null,"finished_at":null,"total":{"records":0,"billable":0,"processed":0,"valid":0,"invalid":0,"catchall":0,"disposable":0,"unknown":0,"duplicates":0,"bad_syntax":0},"bounce_estimate":-1,"percent_complete":0},{"id":276736,"job_status":"queued","filename":"","created_at":"2017-07-25 07:54:29","started_at":null,"finished_at":null,"total":{"records":0,"billable":0,"processed":0,"valid":0,"invalid":0,"catchall":0,"disposable":0,"unknown":0,"duplicates":0,"bad_syntax":0},"bounce_estimate":-1,"percent_complete":0},{"id":274226,"job_status":"complete","filename":"Created from Array.csv","created_at":"2017-07-21 17:33:45","started_at":"2017-07-21 17:33:46","finished_at":"2017-07-21 17:33:47","total":{"records":3,"billable":2,"processed":3,"valid":1,"invalid":2,"catchall":0,"disposable":0,"unknown":0,"duplicates":0,"bad_syntax":1},"bounce_estimate":0,"percent_complete":100}],"execution_time":402}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /Response:/ }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
        expect(lines).to be_any { |s| s =~ /Query:/ }
        expect(lines).to be_any { |s| s =~ cell("Page") }
        expect(lines).to be_any { |s| s =~ cell("PerPage") }
        expect(lines).to be_any { |s| s =~ /Results:/ }
        expect(lines).to be_any { |s| s =~ cell("ID") }
        expect(lines).to be_any { |s| s =~ cell("JobStatus") }
        expect(lines).to be_any { |s| s =~ cell("Filename") }
        expect(lines).to be_any { |s| s =~ cell("Total") }
      end
    end
  end
end; end; end
