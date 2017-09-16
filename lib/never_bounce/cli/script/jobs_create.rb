
require "neverbounce"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsCreate < RequestMaker
    require_relative "jobs_create/supplied_input_parser"

    attr_writer :auto_parse, :auto_start, :filename, :input, :input_location, :now, :remote_input, :run_sample, :supplied_input, :supplied_input_array, :supplied_input_parser

    envar "AUTO_PARSE", "Start parsing the job immediately after creation", ["y", "n"]
    envar "FILENAME", "Original CSV filename", [{default: "YYYYMMDD-HHMMSS.csv"}, "My data.csv"]
    envar "REMOTE_INPUT", "Remote URL with CSV of e-mails to verify", ["http://site.com/emails.csv"]
    envar "SUPPLIED_INPUT", "List of e-mails to verify", ["tom@isp.com Tom User;dick@gmail.com Dick Other"]
    envar (k = "AUTO_START"), *SHARED_ENVARS[k]
    envar (k = "RUN_SAMPLE"), *SHARED_ENVARS[k]

    # @return [true]
    # @return [false]
    # @return [nil]
    def auto_parse
      igetset(:auto_parse) do
        if env.has_key?(k = "AUTO_PARSE")
          env_truthy?(k)
        end
      end
    end

    # @return [true]
    # @return [false]
    # @return [nil]
    def auto_start
      igetset(:auto_start) do
        if env.has_key?(k = "AUTO_START")
          env_truthy?(k)
        end
      end
    end

    def filename
      igetset(:filename) { env["FILENAME"] || now.strftime("%Y%m%d-%H%M%S.csv") }
    end

    # @return [String] An URL if remote input.
    # @return [Array] An array of e-mails if supplied input.
    def input
      input_location    # Touch for sanity/completeness checks etc.
      remote_input || supplied_input_array
    end

    # @return [String] <tt>"remote_url"</tt> or <tt>"supplied"</tt>
    def input_location
      @input_location ||= begin
        # Sanity check.
        raise UsageError, "`REMOTE_INPUT` and `SUPPLIED_INPUT` can't both be given" if remote_input? && supplied_input?

        if remote_input?
          "remote_url"
        elsif supplied_input?
          "supplied"
        else
          raise UsageError, "Input not given, use `REMOTE_INPUT=` or `SUPPLIED_INPUT=`"
        end
      end
    end

    def now
      @now ||= Time.now
    end

    def remote_input
      igetset(:remote_input) { env["REMOTE_INPUT"] }
    end

    def remote_input?
      !!remote_input
    end

    # @return [true]
    # @return [false]
    # @return [nil]
    def run_sample
      igetset(:run_sample) do
        if env.has_key?(k = "RUN_SAMPLE")
          env_truthy?(k)
        end
      end
    end

    def supplied_input
      igetset(:supplied_input) { env["SUPPLIED_INPUT"] }
    end

    def supplied_input?
      !!supplied_input
    end

    def supplied_input_array
      @supplied_input_array ||= require_attr(:supplied_input_parser)[require_attr(:supplied_input)]
    end

    def supplied_input_parser
      @supplied_input_parser ||= SuppliedInputParser.new
    end

    # An <tt>API::Request::JobsCreate</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsCreate.new({
        api_key: api_key,
        auto_parse: auto_parse,
        auto_start: auto_start,
        filename: filename,
        input: input,
        input_location: input_location,
        run_sample: run_sample,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-create",
        function: "Create a job",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
          ["JobId", :job_id],

          ["ExecTime", :execution_time, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      0
    end
  end
end; end; end
