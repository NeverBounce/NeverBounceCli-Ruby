
require "neverbounce"

require "never_bounce/cli/script/feature/requires_job_id"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsStatus < RequestMaker
    Script::Feature::RequiresJobId.load(self)

    # An <tt>API::Request::JobsStatus</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsStatus.new({
        api_url: api_url,
        api_key: api_key,
        job_id: job_id,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-status",
        function: "Get job status",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
          ["ID", :id, :right],

          ["JStatus", :job_status, :center],
          ["BncEst", ->(r) { r.bounce_estimate.round(2) }, :right],
          ["Complete%", :percent_complete, :right],

          [
            "At",
            ->(r) { [
              "Created:#{inil(r.created_at)}",
              "Started:#{inil(r.started_at)}",
              "Finished:#{inil(r.finished_at)}",
            ].join("\n") },
            :right,
          ],

          ["Filename", :filename],

          ["ExecTime", :execution_time, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      "Total".tap do |label|
        headings = [
          ["BadSyntax", :bad_syntax, :right],
          ["Billable", :billable, :right],
          ["Catchall", :catchall, :right],
          ["Disposable", :disposable, :right],
          ["Duplicates", :duplicates, :right],
          ["Invalid", :invalid, :right],
          ["Processed", :processed, :right],
          ["Records", :records, :right],
          ["Unknown", :unknown, :right],
          ["Valid", :valid, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response.total, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      0
    end
  end
end; end; end
