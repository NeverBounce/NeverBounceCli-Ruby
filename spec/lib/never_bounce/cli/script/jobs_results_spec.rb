
module NeverBounce; module CLI; module Script
  describe JobsResults do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "ID=12"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-results/, /PAGE/, /PER_PAGE/]

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv)
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4/jobs/results", "--header", "Content-Type: application/json", "--data-binary", "{\"job_id\":\"12\",\"key\":\"abc\",\"items_per_page\":1000,\"page\":1}"]
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","total_results":3,"total_pages":1,"query":{"job_id":274226,"valids":1,"invalids":1,"disposables":1,"catchalls":1,"unknowns":1,"page":1,"items_per_page":1000},"results":[{"data":{"email":"email","id":"id","name":"name"},"verification":{"result":"invalid","flags":[],"suggested_correction":"","address_info":{"original_email":"email","normalized_email":"","addr":"","alias":"","host":"","fqdn":"","domain":"","subdomain":"","tld":""}}},{"data":{"email":"support@neverbounce.com","id":"12345","name":"Fred McValid"},"verification":{"result":"valid","flags":["has_dns","has_dns_mx","role_account","smtp_connectable"],"suggested_correction":"","address_info":{"original_email":"support@neverbounce.com","normalized_email":"support@neverbounce.com","addr":"support","alias":"","host":"neverbounce.com","fqdn":"neverbounce.com","domain":"neverbounce","subdomain":"","tld":"com"}}},{"data":{"email":"invalid@neverbounce.com","id":"12346","name":"Bob McInvalid"},"verification":{"result":"invalid","flags":["has_dns","has_dns_mx","smtp_connectable"],"suggested_correction":"","address_info":{"original_email":"invalid@neverbounce.com","normalized_email":"invalid@neverbounce.com","addr":"invalid","alias":"","host":"neverbounce.com","fqdn":"neverbounce.com","domain":"neverbounce","subdomain":"","tld":"com"}}}],"execution_time":53}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /Response:/ }
        expect(lines).to be_any { |s| s =~ cell("nPages") }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
        expect(lines).to be_any { |s| s =~ /Query:/ }
        expect(lines).to be_any { |s| s =~ cell("JobId") }
        expect(lines).to be_any { |s| s =~ cell("PerPage") }
        expect(lines).to be_any { |s| s =~ /Results:/ }
        expect(lines).to be_any { |s| s =~ cell("Email") }
        expect(lines).to be_any { |s| s =~ cell("SuggCorr") }
      end
    end
  end
end; end; end
