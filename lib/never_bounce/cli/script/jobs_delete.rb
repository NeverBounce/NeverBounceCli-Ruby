
require "neverbounce"

require "never_bounce/cli/script/feature/requires_job_id"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsDelete < RequestMaker
    Script::Feature::RequiresJobId.load(self)

    # An <tt>API::Request::JobsDelete</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsDelete.new({
        api_key: api_key,
        job_id: job_id,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-delete",
        function: "Delete a job",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
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
