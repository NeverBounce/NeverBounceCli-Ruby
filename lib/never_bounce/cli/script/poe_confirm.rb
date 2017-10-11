
require "neverbounce"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class POEConfirm < RequestMaker

    attr_writer :email, :transaction_id, :confirmation_token, :result

    envar "EMAIL*", "The email that was verified ", ["alice@isp.com", "bob.smith+1@domain.com"]
    envar "TRANSACTION_ID*", "The transaction id returned by the public verification", ["NBTRNS-123456"]
    envar "CONFIRMATION_TOKEN*", "The confirmation_token returned by the public verification", ["abcdefg123456"]
    envar "RESULT*", "The result returned by the public verification", ["valid", "invalid", "catchall", "disposable", "unknown"]

    def email
      @email ||= env[k = "EMAIL"] or raise UsageError, "E-mail address not given, use `#{k}=`"
    end

    def transaction_id
      @transaction_id ||= env[k = "TRANSACTION_ID"] or raise UsageError, "Transaction ID was not given, use `#{k}=`"
    end

    def confirmation_token
      @confirmation_token ||= env[k = "CONFIRMATION_TOKEN"] or raise UsageError, "Confirmation Token was not given, use `#{k}=`"
    end

    def result
      @result ||= env[k = "RESULT"] or raise UsageError, "Result was not given, use `#{k}=`"
    end

    # An <tt>API::Request::POEConfirm</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::POEConfirm.new({
        api_key: api_key,
        email: email,
        transaction_id: transaction_id,
        confirmation_token: confirmation_token,
        result: result,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-poe-confirm",
        function: "Verify a verification performed on the frontend with the Javascript Wdiget",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      "Response".tap do |label|
        headings = [
          ["TokenConfirmed", :token_confirmed],

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
