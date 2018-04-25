
require "neverbounce"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class AccountInfo < RequestMaker
    # An <tt>API::Request::AccountInfo</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::AccountInfo.new({
        api_url: api_url,
        api_key: api_key,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-account-info",
        function: "Check account balance",
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

      "Credits".tap do |label|
        headings = [
          ["FreeRmn", :free_credits_remaining, :right],
          ["FreeUsed", :free_credits_used, :right],
          (["MonthlyUsage", :monthly_api_usage, :right] if response.credits_info.monthly?),
          (["PaidRmn", :paid_credits_remaining, :right] if response.credits_info.paid?),
          (["PaidUsed", :paid_credits_used, :right] if response.credits_info.paid?),
        ].compact

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response.credits_info, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      "JobCounts".tap do |label|
        headings = [
          ["Completed", :completed, :right],
          ["Processing", :processing, :right],
          ["Queued", :queued, :right],
          ["UnderReview", :under_review, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response.job_counts, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      0
    end
  end
end; end; end
