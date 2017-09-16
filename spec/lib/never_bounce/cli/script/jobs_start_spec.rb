
module NeverBounce; module CLI; module Script
  describe JobsStart do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc", "ID=12"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-start/, /ID/, /RUN_SAMPLE/]

    describe "mode attributes" do
      describe "#run_sample" do
        let(:m) { :run_sample }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect(newo(env: {"RUN_SAMPLE" => "y"}).send(m)).to be true
          expect(newo(env: {"RUN_SAMPLE" => "n"}).send(m)).to be false
        end
      end
    end

    describe "#request_curl" do
      it "generally works" do
        r = goodo(argv: margv("RUN_SAMPLE=y"))
        expect(r.request_curl).to eq ["--request", "POST", "--url", "https://api.neverbounce.com/v4/jobs/start", "--header", "Content-Type: application/json", "--data-binary", "{\"job_id\":\"12\",\"key\":\"abc\",\"run_sample\":true}"]
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","queue_id":"NB-PQ-598B5ED572898","execution_time":25}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /Response:/ }
        expect(lines).to be_any { |s| s =~ cell("QueueId") }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
      end
    end
  end
end; end; end
