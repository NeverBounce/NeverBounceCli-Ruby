
module NeverBounce; module CLI; module Script
  describe JobsDownload do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "ID=12"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-download/, /ID/]

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv)
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4/jobs/download", "--header", "Content-Type: application/json", "--data-binary", "{\"job_id\":\"12\",\"key\":\"abc\"}"]
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          # NOTE: Raw content is actually multiline.
          _.session.server_content_type = "application/octet-stream"
          _.session.server_raw = 'id,email,name,email_status
  "12345","support@neverbounce.com","Fred McValid",valid
  "12346","invalid@neverbounce.com","Bob McInvalid",invalid'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /id,email,name,email_status/ }
        expect(lines).to be_any { |s| s =~ /"Fred McValid"/ }
        expect(lines).to be_any { |s| s =~ /"Bob McInvalid"/ }
      end
    end
  end
end; end; end
