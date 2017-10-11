
module NeverBounce; module CLI; module Script
  describe POEConfirm do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "EMAIL=alice@isp.com", "TRANSACTION_ID=NBTRNS-123456", "CONFIRMATION_TOKEN=abcdefg123456", "RESULT=valid"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-poe-confirm/, /EMAIL/, /TRANSACTION_ID/, /CONFIRMATION_TOKEN/, /RESULT/]

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv())
        expect(r.request_curl).to eq ["--request", "GET", "--url", "https://api.neverbounce.com/v4/poe/confirm", "--header", "Content-Type: application/json", "--data-binary", "{\"email\":\"alice@isp.com\",\"transaction_id\":\"NBTRNS-123456\",\"confirmation_token\":\"abcdefg123456\",\"result\":\"valid\",\"key\":\"abc\"}"]
      end
    end



    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","token_confirmed":true,"execution_time":25}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /Response:/ }
        expect(lines).to be_any { |s| s =~ cell("TokenConfirmed") }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
      end
    end
  end
end; end; end
