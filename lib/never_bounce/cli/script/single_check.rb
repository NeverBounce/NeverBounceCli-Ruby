
require "neverbounce"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class SingleCheck < RequestMaker
    attr_writer :address_info, :email, :credits_info, :timeout

    envar "ADDRESS_INFO", "Request additional address info", ["y", "n"]
    envar "EMAIL*", "E-mail to check", ["alice@isp.com", "bob.smith+1@domain.com"]
    envar "CREDITS_INFO", "Request additional credits info", ["y", "n"]
    envar "TIMEOUT", "Timeout in seconds to verify the address", ["5"]

    # @return [true]
    # @return [false]
    # @return [nil]
    def address_info
      igetset(:address_info) do
        if env.has_key?(k = "ADDRESS_INFO")
          env_truthy?(k)
        end
      end
    end

    # @return [true]
    # @return [false]
    # @return [nil]
    def credits_info
      igetset(:credits_info) do
        if env.has_key?(k = "CREDITS_INFO")
          env_truthy?(k)
        end
      end
    end

    def email
      @email ||= env[k = "EMAIL"] or raise UsageError, "E-mail address not given, use `#{k}=`"
    end

    # An <tt>API::Request::SingleCheck</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::SingleCheck.new({
        api_url: api_url,
        address_info: address_info,
        api_key: api_key,
        credits_info: credits_info,
        email: email,
        timeout: timeout,
      })
    end

    def timeout
      igetset(:timeout) do
        if (v = env["TIMEOUT"])
          begin
            Integer(v)
          rescue ArgumentError => e
            raise UsageError, e.message
          end
        end
      end
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-single-check",
        function: "Check a single e-mail",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
          ["Result", :result, :center],
          [
            "Flags",
            ->(r) { r.flags.sort.join("\n") },
          ],
          ["SuggCorr", :suggested_correction],

          ["ExecTime", :execution_time, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      response.address_info? and "AddressInfo".tap do |label|
        headings = [
          ["Addr", :addr],
          ["Alias", :alias],
          ["Domain", :domain],
          ["FQDN", :fqdn],
          ["Host", :host],
          ["NormEmail", :normalized_email],
          ["OrigEmail", :original_email],
          ["Subdomain", :subdomain],
          ["TLD", :tld],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response.address_info, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end # response.address_info?

      response.credits_info? and "CreditsInfo".tap do |label|
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
      end # response.credits_info?

      0
    end
  end
end; end; end
