
module NeverBounce; module CLI; module Script
  describe AccountInfo do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-account-info/]

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv)
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4.1/account/info", "--header", "Content-Type: application/json", "--data-binary", "{\"key\":\"abc\"}"]
      end
    end

    describe "output" do
      context "when monthly subscription" do
        it "generally works" do
          r = goodo(argv: margv).tap do |_|
            _.session.server_content_type = "application/json"
            _.session.server_raw = '{"credits_info":{"free_credits_remaining":1000,"free_credits_used":0,"monthly_api_usage":0},"execution_time":405,"job_counts":{"completed":3,"processing":0,"queued":0,"under_review":0},"status":"success"}'
          end

          expect { r.main }.not_to raise_error
          lines = r.stdout.tap(&:rewind).to_a
          expect(lines).to be_any { |s| s =~ /^Response:$/ }
          expect(lines).to be_any { |s| s =~ cell("ExecTime") }
          expect(lines).to be_any { |s| s =~ /^Credits:$/ }
          expect(lines).to be_any { |s| s =~ cell("FreeRmn") }
          expect(lines).to be_any { |s| s =~ cell("FreeUsed") }
          expect(lines).to be_any { |s| s =~ cell("MonthlyUsage") }
          expect(lines).to be_any { |s| s =~ /^JobCounts:$/ }
          expect(lines).to be_any { |s| s =~ cell("Completed") }
          expect(lines).to be_any { |s| s =~ cell("UnderReview") }
        end
      end

      context "when paid subscription" do
        it "generally works" do
          r = goodo(argv: margv).tap do |_|
            _.session.server_content_type = "application/json"
            _.session.server_raw = '{"status":"success","credits_info":{"paid_credits_used":0,"free_credits_used":0,"paid_credits_remaining":1000000,"free_credits_remaining":959},"job_counts":{"completed":1,"under_review":0,"queued":0,"processing":0},"execution_time":525}'
          end

          expect { r.main }.not_to raise_error
          lines = r.stdout.tap(&:rewind).to_a
          expect(lines).to be_any { |s| s =~ /^Response:$/ }
          expect(lines).to be_any { |s| s =~ cell("ExecTime") }
          expect(lines).to be_any { |s| s =~ /^Credits:$/ }
          expect(lines).to be_any { |s| s =~ cell("FreeRmn") }
          expect(lines).to be_any { |s| s =~ cell("FreeUsed") }
          expect(lines).to be_any { |s| s =~ cell("PaidRmn") }
          expect(lines).to be_any { |s| s =~ cell("PaidUsed") }
          expect(lines).to be_any { |s| s =~ /^JobCounts:$/ }
          expect(lines).to be_any { |s| s =~ cell("Completed") }
          expect(lines).to be_any { |s| s =~ cell("UnderReview") }
        end
      end
    end # describe "output"
  end
end; end; end
