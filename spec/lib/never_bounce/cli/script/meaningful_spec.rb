
describe NeverBounce::CLI::Script::Meaningful do
  include_dir_context __dir__

  it_behaves_like "instantiatable"

  describe "command-line options" do
    it "generally works" do
      r = goodo(
        argv: ["A=1", "B=2  3", "C== hey\nthere ="],
        env: {},
      )
      expect { r.options }.not_to raise_error
      expect(r.env).to eq({"A" => "1", "B" => "2  3", "C" => "= hey\nthere ="})
    end
  end

  describe "successor class" do
    # Generic successor class.
    # Hack: We define it in both scopes to be able to use shared examples.
    the_klass = Class.new(described_class) do
      envar "AA", "No examples"
      envar "AB", "Some examples", ["a", "b"]
      envar "AC", "Examples with a default", ["a", {default: "B"}, "c"]
      envar "AD", "Numeric examples with a default", [1, default: 10]
      envar "BA*", "Mandatory. No examples"
      envar "BB*", "Mandatory. Some examples", ["a", "b"]
      envar "CAaaaaaa", "Longer name"

      def manifest
        @manifest ||= Class.new do
          def cmdline
            "[some_options]"
          end

          def function
            "some function"
          end

          def name
            "some-name"
          end
        end.new
      end

      def slim_main
        stdout.puts "I'm slim_main"
        12
      end
    end

    let(:klass) do
      # Copy local scope variable to example scope.
      the_klass
    end

    def newo(attrs = {})
      klass.new(attrs)
    end

    it_behaves_like "a script supporting `--help`", klass: the_klass, signatures: [/some-name/, /some_options/]

    describe "usage text" do
      describe "#banner_text" do
        it "generally works" do
          expect(newo.banner_text).to eq "some-name - some function"
        end
      end

      describe "#envar_text" do
        it "generally works" do
          expect(newo.envar_text).to eq "* BA       - Mandatory. No examples\n* BB       - Mandatory. Some examples (\"a\", \"b\")\n- AA       - No examples\n- AB       - Some examples (\"a\", \"b\")\n- AC       - Examples with a default (\"a\", [\"B\"], \"c\")\n- AD       - Numeric examples with a default (1, [10])\n- CAaaaaaa - Longer name"
        end
      end

      describe "#help_text" do
        it "generally works" do
          r = newo
          expect(r.help_text).to match /\bsome-name\b/
          expect(r.help_text).to match /\bUSAGE:\s/
          expect(r.help_text).to match /\bEnvironment variables:\s/
        end
      end
    end # describe "usage text"

    it "generally works" do
      r = newo(argv: [], env: {}, stdout: StringIO.new)
      expect(r.main).to eq 12
      lines = r.stdout.tap(&:rewind).to_a
      expect(lines).to eq ["I'm slim_main\n"]
    end
  end # successor class
end
