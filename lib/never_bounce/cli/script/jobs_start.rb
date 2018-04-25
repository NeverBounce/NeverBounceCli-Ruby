
require "neverbounce"

require "never_bounce/cli/script/feature/requires_job_id"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsStart < RequestMaker
    Script::Feature::RequiresJobId.load(self)

    attr_writer :run_sample

    envar (k = "RUN_SAMPLE"), *SHARED_ENVARS[k]

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

    # An <tt>API::Request::JobsStart</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsStart.new({
        api_url: api_url,
        api_key: api_key,
        job_id: job_id,
        run_sample: run_sample,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-start",
        function: "Start a job created with `auto_start` disabled",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
          ["QueueId", :queue_id],

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
