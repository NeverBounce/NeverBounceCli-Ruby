
shared_context __dir__ do
  # Build a regexp to match a text cell value.
  def cell(value)
    Regexp.compile '\|\s*?' + value.to_s + '\s*?\|'
  end

  # Create a "good" script object which is about to do some real processing.
  def goodo(attrs = {})
    # This thing is much over the top for a regular "new object", hence a unique name `goodo`.
    # Stuff empty `argv` for convenience. It'll be overridden by `merge` if needed.
    # Otherwise it'll fetch args given to `rspec`, which has no point.
    described_class.new({
      argv: [],
      env: {},    # We don't want RSpec invocation environment to interfere.
      stderr: (stderr = StringIO.new),
      stdout: (stdout = StringIO.new),
    }.merge(attrs)).tap do |_|
      # IMPORTANT: We *MUST* call `handle_help_and_options` to read ENV settings from `argv`.
      #   We add expectation here since we have to call that thing anyway.
      #   It's mostly due to screwed `OptionParser` logic.
      #expect(_.handle_help_and_options).to be_nil
      res = _.handle_help_and_options
      if not res.nil?
        # Print all messages and errors from the script.
        puts stdout.tap(&:rewind).to_a
        STDERR.puts stderr.tap(&:rewind).to_a
        expect(res).to be nil   # Make it fail now.
      end
    end
  end

  # Usage:
  #
  #   it_behaves_like "..."
  #   it_behaves_like "...", klass: the_klass
  #   it_behaves_like "...", signatures: [/nb-jobs-delete/, /ID/]
  shared_examples "a script supporting `--help`" do |klass: described_class, signatures: nil|
    it "generally works" do
      # Validate arguments.
      expect(signatures).to be_a Array

      r = klass.new(
        argv: ["--help"],
        stdout: StringIO.new,
      )

      out = nil
      expect { out = r.main }.not_to raise_error
      expect(out).to be 0

      lines = r.stdout.tap(&:rewind).to_a
      expect(lines).to be_any { |s| s =~ /USAGE/ }
      signatures.each do |re|
        expect(lines).to be_any { |s| s =~ re }
      end
    end
  end
end
