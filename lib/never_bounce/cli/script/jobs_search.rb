
require "neverbounce"

require "never_bounce/cli/script/feature/uses_pagination"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsSearch < RequestMaker
    Script::Feature::UsesPagination.load(self)

    attr_writer :job_id

    envar "ID", "Filter by Job ID", ["276816"]

    # Job ID. Default is <tt>env["ID"]</tt>.
    # @!attribute job_id
    # @return [String]
    def job_id
      igetset(:job_id) { env["ID"] }
    end

    # An <tt>API::Request::JobsSearch</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsSearch.new({
        api_key: api_key,
        job_id: job_id,
        page: page,
        per_page: per_page,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-search",
        function: "List jobs",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
          ["nPages", :total_pages, :right],
          ["nResults", :total_results, :right],

          ["ExecTime", :execution_time, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      "Query".tap do |label|
        headings = [
          ["Page", :page, :right],
          ["PerPage", :items_per_page, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response.query, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      "Results".tap do |label|
        headings = [
          ["ID", :id, :right],
          ["JobStatus", :job_status, :center],
          ["Filename", :filename, :center],
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

          [
            "Total",
            ->(r) { [
              "BadSynt:#{inil(r.total.bad_syntax)}",
              "Billable:#{inil(r.total.billable)}",
              "Catchall:#{inil(r.total.catchall)}",
              "Disp:#{inil(r.total.disposable)}",
              "Dup:#{inil(r.total.duplicates)}",
              "Invalid:#{inil(r.total.invalid)}",
              "Proc'd:#{inil(r.total.processed)}",
              "Records:#{inil(r.total.records)}",
              "Unknown:#{inil(r.total.unknown)}",
              "Valid:#{inil(r.total.valid)}",
            ].join("\n") },
            :right,
          ],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: response.results.map do |r|
            headings.map do |ar|
              get_table_value(r, ar)
            end
          end,
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      0
    end
  end
end; end; end
