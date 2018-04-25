
require "neverbounce"

require "never_bounce/cli/script/feature/requires_job_id"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsParse < RequestMaker
    Script::Feature::RequiresJobId.load(self)

    attr_writer :auto_start

    envar (k = "AUTO_START"), *SHARED_ENVARS[k]

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

    # An <tt>API::Request::JobsParse</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsParse.new({
        api_url: api_url,
        api_key: api_key,
        auto_start: auto_start,
        job_id: job_id,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-parse",
        function: "Issue a job parse command to the server",
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
