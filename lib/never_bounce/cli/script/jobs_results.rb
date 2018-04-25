
require "neverbounce"

require "never_bounce/cli/script/feature/requires_job_id"
require "never_bounce/cli/script/feature/uses_pagination"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsResults < RequestMaker
    Script::Feature::RequiresJobId.load(self)
    Script::Feature::UsesPagination.load(self)

    # An <tt>API::Request::JobsResults</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsResults.new({
        api_url: api_url,
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
        name: "nb-jobs-results",
        function: "Get job execution results",
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
          ["JobId", :job_id, :right],
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
          ["Email", :email],
          ["Result", :result, :center],

          [
            "Flags",
            ->(r) { r.flags.sort.join("\n") },
          ],

          ["SuggCorr", :suggested_correction],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: response.items.map do |r|
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
