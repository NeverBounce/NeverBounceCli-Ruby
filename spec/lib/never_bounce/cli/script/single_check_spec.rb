
module NeverBounce; module CLI; module Script
  describe SingleCheck do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "EMAIL=tom@isp.com"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-single-check/, /ADDRESS_INFO/, /EMAIL/, /CREDITS_INFO/, /TIMEOUT/]

    describe "mode attributes" do
      describe "#address_info" do
        let(:m) { :address_info }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect(newo(env: {"ADDRESS_INFO" => "y"}).send(m)).to be true
          expect(newo(env: {"ADDRESS_INFO" => "n"}).send(m)).to be false
        end
      end

      describe "#credits_info" do
        let(:m) { :credits_info }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect(newo(env: {"CREDITS_INFO" => "y"}).send(m)).to be true
          expect(newo(env: {"CREDITS_INFO" => "n"}).send(m)).to be false
        end
      end

      describe "#timeout" do
        let(:m) { :timeout }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect { newo(env: {"TIMEOUT" => "abc"}).send(m) }.to raise_error(UsageError, "invalid value for Integer(): \"abc\"")
          expect(newo(env: {"TIMEOUT" => "12"}).send(m)).to be 12
        end
      end
    end

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv("ADDRESS_INFO=y", "CREDITS_INFO=y", "TIMEOUT=12"))
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4/single/check", "--header", "Content-Type: application/json", "--data-binary", "{\"email\":\"tom@isp.com\",\"key\":\"abc\",\"address_info\":true,\"credits_info\":true,\"timeout\":12}"]
      end
    end

    describe "output" do
      context "when monthly subscription" do
        it "generally works" do
          r = goodo(argv: margv).tap do |_|
            _.session.server_content_type = "application/json"
            _.session.server_raw = '{"address_info":{"addr":"support","alias":"","domain":"neverbounce","fqdn":"neverbounce.com","host":"neverbounce.com","normalized_email":"support@neverbounce.com","original_email":"support@neverbounce.com","subdomain":"","tld":"com"},"credits_info":{"free_credits_remaining":999,"free_credits_used":1,"monthly_api_usage":0},"execution_time":678,"flags":["has_dns","has_dns_mx","role_account","smtp_connectable"],"result":"valid","status":"success","suggested_correction":""}'
          end
          expect { r.main }.not_to raise_error
          lines = r.stdout.tap(&:rewind).to_a
          expect(lines).to be_any { |s| s =~ /Response:/ }
          expect(lines).to be_any { |s| s =~ cell("Result") }
          expect(lines).to be_any { |s| s =~ cell("ExecTime") }
          expect(lines).to be_any { |s| s =~ /AddressInfo:/ }
          expect(lines).to be_any { |s| s =~ cell("Addr") }
          expect(lines).to be_any { |s| s =~ cell("TLD") }
          expect(lines).to be_any { |s| s =~ /CreditsInfo:/ }
          expect(lines).to be_any { |s| s =~ cell("FreeRmn") }
          expect(lines).to be_any { |s| s =~ cell("FreeUsed") }
          expect(lines).to be_any { |s| s =~ cell("MonthlyUsage") }
        end
      end

      context "when paid subscription" do
        it "generally works" do
          r = goodo(argv: margv).tap do |_|
            _.session.server_content_type = "application/json"
            _.session.server_raw = '{"status":"success","result":"valid","flags":["contains_alias","smtp_connectable","has_dns","has_dns_mx"],"suggested_correction":"","address_info":{"original_email":"fortunadze+1@gmail.com","normalized_email":"fortunadze@gmail.com","addr":"fortunadze","alias":"1","host":"gmail.com","fqdn":"gmail.com","domain":"gmail","subdomain":"","tld":"com"},"credits_info":{"paid_credits_used":0,"free_credits_used":1,"paid_credits_remaining":1000000,"free_credits_remaining":941},"execution_time":189}'
          end
          expect { r.main }.not_to raise_error
          lines = r.stdout.tap(&:rewind).to_a
          expect(lines).to be_any { |s| s =~ /Response:/ }
          expect(lines).to be_any { |s| s =~ cell("Result") }
          expect(lines).to be_any { |s| s =~ cell("ExecTime") }
          expect(lines).to be_any { |s| s =~ /AddressInfo:/ }
          expect(lines).to be_any { |s| s =~ cell("Addr") }
          expect(lines).to be_any { |s| s =~ cell("TLD") }
          expect(lines).to be_any { |s| s =~ /CreditsInfo:/ }
          expect(lines).to be_any { |s| s =~ cell("FreeRmn") }
          expect(lines).to be_any { |s| s =~ cell("FreeUsed") }
          expect(lines).to be_any { |s| s =~ cell("PaidRmn") }
          expect(lines).to be_any { |s| s =~ cell("PaidUsed") }
        end
      end
    end
  end
end; end; end
