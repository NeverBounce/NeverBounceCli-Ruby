
module NeverBounce; module CLI; module Script
  describe JobsCreate do
    include_dir_context __dir__

    def margv(*args)
      ["API_KEY=abc"] + args
    end

    it_behaves_like "instantiatable"
    it_behaves_like "a script supporting `--help`", signatures: [/nb-jobs-create/, /AUTO_PARSE/, /AUTO_START/, /FILENAME/, /REMOTE_INPUT/, /RUN_SAMPLE/, /SUPPLIED_INPUT/]

    describe "mode attributes" do
      describe "#auto_parse" do
        let(:m) { :auto_parse }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect(newo(env: {"AUTO_PARSE" => "y"}).send(m)).to be true
          expect(newo(env: {"AUTO_PARSE" => "n"}).send(m)).to be false
        end
      end

      describe "#auto_start" do
        let(:m) { :auto_start }
        it "generally works" do
          expect(newo(env: {}).send(m)).to be nil
          expect(newo(env: {"AUTO_START" => "y"}).send(m)).to be true
          expect(newo(env: {"AUTO_START" => "n"}).send(m)).to be false
        end
      end

      describe "#run_sample" do
        it "generally works" do
          expect(newo(env: {}).run_sample).to be nil
          expect(newo(env: {"RUN_SAMPLE" => "y"}).run_sample).to be true
          expect(newo(env: {"RUN_SAMPLE" => "n"}).run_sample).to be false
        end
      end
    end # describe "mode attributes"

    describe "#input_location" do
      let(:m) { :input_location }
      it "generally works" do
        r = newo(env: {})
        expect { r.send(m) }.to raise_error(UsageError, "Input not given, use `REMOTE_INPUT=` or `SUPPLIED_INPUT=`")
        r = newo(env: {"REMOTE_INPUT" => "remote_input"})
        expect(r.send(m)).to eq "remote_url"
        r = newo(env: {"SUPPLIED_INPUT" => "supplied_input"})
        expect(r.send(m)).to eq "supplied"
        r = newo(env: {"REMOTE_INPUT" => "remote_input", "SUPPLIED_INPUT" => "supplied_input"})
        expect { r.send(m) }.to raise_error(UsageError, "`REMOTE_INPUT` and `SUPPLIED_INPUT` can't both be given")
      end
    end

    describe "attributes" do
      describe "#filename" do
        it "has a time-based default value" do
          r = newo(now: Time.new(2017, 12, 18, 11, 22, 33))
          expect(r.filename).to eq "20171218-112233.csv"
        end

        it "generally works" do
          r = newo(env: {"FILENAME" => "abc"})
          expect(r.filename).to eq "abc"
        end
      end

      describe "#remote_input" do
        it "generally works" do
          expect(newo(env: {}).remote_input).to be nil
          expect(newo(env: {"REMOTE_INPUT" => "remote_input"}).remote_input).to eq "remote_input"
        end
      end
    end # describe "attributes"

    describe "#request_curl" do
      context "when remote input" do
        it "generally works" do
          r = goodo(argv: margv(
            "AUTO_PARSE=y",
            "AUTO_START=y",
            "FILENAME=filename",
            "REMOTE_INPUT=remote_input",
            "RUN_SAMPLE=y",
          ))
          expect(r.request_curl).to eq ["--request", "POST", "--url", "https://api.neverbounce.com/v4/jobs/create", "--header", "Content-Type: application/json", "--data-binary", "{\"input\":\"remote_input\",\"input_location\":\"remote_url\",\"filename\":\"filename\",\"key\":\"abc\",\"auto_start\":true,\"auto_parse\":true,\"run_sample\":true}"]
        end
      end

      context "when supplied input" do
        it "generally works" do
          r = goodo(argv: margv(
            "AUTO_PARSE=y",
            "AUTO_START=y",
            "FILENAME=filename",
            "RUN_SAMPLE=y",
            "SUPPLIED_INPUT=tom@isp.com;dick@domain.com",
          ))
          expect(r.request_curl).to eq ["--request", "POST", "--url", "https://api.neverbounce.com/v4/jobs/create", "--header", "Content-Type: application/json", "--data-binary", "{\"input\":[[\"tom@isp.com\",\"\"],[\"dick@domain.com\",\"\"]],\"input_location\":\"supplied\",\"filename\":\"filename\",\"key\":\"abc\",\"auto_start\":true,\"auto_parse\":true,\"run_sample\":true}"]
        end
      end
    end

    describe "output" do
      it "generally works" do
        r = goodo(argv: margv("SUPPLIED_INPUT=tom@isp.com")).tap do |_|
          _.session.server_content_type = "application/json"
          _.session.server_raw = '{"status":"success","job_id":348530,"execution_time":602}'
        end
        expect { r.main }.not_to raise_error
        lines = r.stdout.tap(&:rewind).to_a
        expect(lines).to be_any { |s| s =~ /Response:/ }
        expect(lines).to be_any { |s| s =~ cell("JobId") }
        expect(lines).to be_any { |s| s =~ cell("ExecTime") }
      end
    end
  end
end; end; end
