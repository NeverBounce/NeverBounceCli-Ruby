
require "optparse"

require "never_bounce/cli/feature/envars"
require "never_bounce/cli/script/error"
require "never_bounce/cli/script/manifest"    # Provide successors with the class they'll need.

require_relative "base"

module NeverBounce; module CLI; module Script
  # A meaningful base script class. Features:
  #
  # * Handle command-line options.
  # * Handle envars.
  # * Handle boilerplate actions like printing usage on `--help`.
  #
  # @abstract
  # @see CLI::Feature::Envars
  # @see CLI::Feature::Igetset
  class Meaningful < Base
    CLI::Feature::Envars.load(self)
    CLI::Feature::Igetset.load(self)

    attr_writer :banner_text, :envar_text, :help_text, :manifest, :options_text

    # @return [String]
    def banner_text
      @banner_text ||= "#{manifest.name} - #{manifest.function}"
    end

    # @return [String]
    def envar_text
      @envar_text ||= begin
        max_width = (envars = self.class.envars).map(&:name).map(&:size).max
        envars.sort_by { |_| [_.mandatory?? 0 : 1, _.name] }.map do |r|
          "%s %-#{max_width}s - %s%s" % [
            (r.mandatory?? "*" : "-"),
            r.name,
            r.comment,
            (s = self.class.format_envar_examples(r)) ? " (#{s})" : "",
          ]
        end.join("\n")
      end
    end

    # Exception classes which are rescued fromc in {#main} and printed to user.
    # @note Should be a few very high-level excaptions which you fully control.
    # @return [Array]
    def self.error_klasses
      [Error]
    end

    # <tt>true</tt> if help has been requested via command-line options.
    def help?
      !!options[:help]
    end

    def help_text
      @help_text ||= begin
        [
          banner_text,
          "",
          "USAGE: #{manifest.name} #{manifest.cmdline}",
          "",
          options_text,
          "",
          "Environment variables:",
          envar_text,
        ].join("\n")
      end
    end

    # Parse command-line options with <tt>OptionParser</tt>.
    #
    #   options   # => {:help => true}
    #
    # @note This isn't an attribute and there's no writer for it. For simulation and testing
    #   we use {#argv=}.
    # @return [Hash]
    def options
      @options ||= begin
        h = {}

        @option_parser = OptionParser.new do |opts|
          opts.banner = ""    # A hack to remove Ruby's "-e".

          opts.on("-h", "--help", "Show help information") do
            h[:help] = true
          end
        end

        rmn_options = begin
          @option_parser.parse!(argv)
        rescue OptionParser::ParseError => e
          (h[:errors] ||= []) << "Error: #{e.message}"
          retry
        end

        # Parse and add "KEY=value" options to environment.
        rmn_options.reject! do |s|
          if s =~ /^(\w+)=(.*)$/m     # NOTE: `/m` allows for multiline options.
            env[$1] = $2
            true
          end
        end

        # Treat remaining options as errors.
        # If this behaviour changes, we should provide access to `rmn_options` via method.
        rmn_options.each do |s|
          (h[:errors] ||= []) << "Error: unexpected option: #{s}"
        end

        h
      end
    end

    # Our <tt>OptionParser</tt> object.
    def option_parser
      options if not @options
      @option_parser
    end

    def options_text
      @options_text ||= option_parser.help.strip
    end

    #---------------------------------------

    # Invoke one of the slim_main methods available in self.
    #
    #   call_slim_main(3)   # Try <tt>slim_main3</tt>, then <tt>slim_main2</tt> down to <tt>slim_main</tt>.
    #
    # @return [Integer] Result of <tt>slim_main[N]</tt>.
    def call_slim_main(from_level = 3)
      from_level.downto(0) do |i|
        if respond_to?(m = "slim_main#{i > 0 ? i : ''}")
          return send(m)
        end
      end

      # This is in theory possible, stay sane.
      raise "No `slim_main` responded, check your class hierarchy"
    end
    private :call_slim_main

    #--------------------------------------- `main` and its friends

    # Format an envar examples string.
    #
    #   format_examples_string(envar)   # => ""a", *"B""
    #
    # @return [String] Insertion-ready string or <tt>nil</tt> if envar doesn't have examples.
    def self.format_envar_examples(envar)
      return nil if envar.examples.empty?

      envar.examples.map do |v|
        if envar.default and v == envar.default
          "[" + v.inspect + "]"
        else
          v.inspect
        end
      end.join(", ")
    end

    # Handle help request and invalid options.
    # @note See method source for important details.
    # @return [Integer] Program exit code (0, 1) if the program should exit now.
    # @return [nil] If all okay.
    def handle_help_and_options
      # NOTES:
      #
      # * Due to `OptionParser` specifics we don't use on-the-fly handling of options.
      #   We do it procedurally instead, to avoid running into a circular dependency.
      #   Thus, it's okay to call this method directly in specs as long as `argv` is concerned.
      # * The method has internal protection to ensure it's called just ones to make speccing a bit easier.
      igetset(:handle_help_and_options) do
        if help?
          # We ignore errors if there's a help request.
          stdout.puts help_text
          0
        elsif (ar = options[:errors])
          stderr.puts ar
          1
        end
      end
    end

    # Program manifest object. Successors should return it.
    # @abstract
    # @return [Manicest]
    def manifest
      raise NotImplementedError, "Redefine `manifest` in your class: #{self.class}"
    end

    # Main routine which handles most boilerplate.
    # @return [Integer]
    # @see #slim_main
    def main
      # Handle top-level errors like `UsageError`.
      begin
        if (res = handle_help_and_options)
          return res
        end

        # Invoke dump'n'exit, if `def dx` defined.
        # NOTE: This code is production-compatible. It's active only if final script responds to `dx`, which is strictly debug-time.
        if respond_to? :dx and env_truthy? "DX"
          dx
          return 1
        end

        # Do it.
        result = call_slim_main

        # Help us stay sane.
        raise "Unknown `slim_main` result: #{result.inspect}" if not result.is_a? Integer

        result
      rescue *self.class.error_klasses => e
        stderr.puts "#{e.class.to_s.split('::').last}: #{e.message}"    # Like "UsageError: this and that".
        1
      end
    end

    # Slim or "real" main routine of the successor class.
    # Called by {#main} considering all boilerplate has been taken care of.
    # @abstract
    # @return [Integer]
    def slim_main
      raise NotImplementedError, "Redefine `slim_main` in your class: #{self.class}"
    end
  end
end; end; end
