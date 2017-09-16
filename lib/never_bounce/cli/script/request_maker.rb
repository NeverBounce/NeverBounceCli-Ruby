
require "never_bounce/cli/script/table"
require "never_bounce/cli/user_config"

require_relative "meaningful"

module NeverBounce; module CLI; module Script
  # An API request maker script base class.
  class RequestMaker < Meaningful
    attr_writer :api_key, :request, :request_curl, :response, :server_raw, :session, :user_config

    envar "API_KEY*", "API key", ["2ed45186c72f9319dc64338cdf16ab76b44cf3d1"]
    envar "API_URL", "Custom API URL", ["https://staging-api.isp.com/v5"]
    envar "CURL", "Print cURL request and exit", ["y", default: "N"]
    envar "RAW", "Print raw response body", ["y", default: "N"]

    # Shared envar defaults.
    SHARED_ENVARS = {
      "AUTO_START" => ["Start processing the job immediately after parsing", ["y", "n"]],
      "RUN_SAMPLE" => ["Run this job as a sample", ["y", "n"]],
    }

    # @!attribute api_key
    # @return [String]
    def api_key
      @api_key ||= env["API_KEY"] || user_config.api_key or raise UsageError, "API key not given, use `API_KEY=`"
    end

    # @!attribute api_url
    # @return [String]
    def api_url
      @api_url ||= igetset(:api_url) do
        env["API_URL"] || user_config.api_url
      end
    end

    # An instance of <tt>API::Request::Base</tt> successor.
    # @abstract
    # @!attribute request
    # @return [Object]
    def request
      @request or raise NotImplementedError, "Redefine `request` in your class: #{self.class}"
    end

    # Request's cURL representation. Default is <tt>request.to_curl</tt>
    # @!attribute request_curl
    # @return [Array]
    def request_curl
      require_attr(:request).to_curl
    end

    # An <tt>API::Response::Base</tt> successor instance.
    # @!attribute response
    # @return [Object]
    def response
      @response ||= require_attr(:session).response
    end

    # Raw server response text. Default is <tt>session.server_raw</tt>.
    # This attribute is used by <tt>RAW=y</tt> mode only.
    # @!attribute server_raw
    # @return [String]
    def server_raw
      @server_raw ||= require_attr(:session).server_raw
    end

    # An instance of <tt>API::Session</tt> built around {#request}.
    # @!attribute session
    # @return [Object]
    def session
      @session ||= API::Session.new(request: require_attr(:request))
    end

    # @!attribute user_config
    # @return [UserConfig]
    def user_config
      @user_config ||= UserConfig.new
    end

    #--------------------------------------- Misc

    # Extract response's value according to a heading spec.
    #
    #   get_table_value(reasponse, ["ID", :id, :right])
    def get_table_value(r, hspec)
      if (m = hspec[1]).is_a? Proc
        m.(r)
      else
        r.public_send(m)
      end
    end
    private :get_table_value

    # "Inspect or nil" -- format a scalar for table-friendly output.
    #
    #   inil(5)     # => "5"
    #   inil(nil)   # => "-"
    #
    # @return [String]
    def inil(v)
      v.nil?? "-" : v.inspect
    end
    private :inil

    # Print request as a ready-to-run cURL command. Return 0.
    def print_curl_request
      stdout.puts "curl #{request_curl.map(&:shellescape).join(' ')}"
      0
    end

    # Print error response as a standard table. Return 1.
    #
    #   return print_error_response if response_error?
    def print_error_response
      "ErrorResponse".tap do |label|
        headings = [
          ["Status", :status, :center],
          ["Message", :message],
          ["ExecTime", :execution_time, :right],
        ]

        table = Table.new(
          headings: headings.map { |ar| ar[0] },
          rows: [headings.map { |ar| get_table_value(response, ar) }],
        ).align!(headings)

        stdout.puts "\n#{label}:"
        stdout.puts table
      end

      1
    end

    # Print raw response. Return 0.
    #
    #   return print_raw_response if env_truthy? "RAW"
    def print_server_raw
      stdout.puts server_raw
      0
    end

    #--------------------------------------- Main

    def slim_main1
      # Perform common boilerplate actions.
      return print_curl_request if env_truthy? "CURL"

      # Any of these, unless during tests, touch `response`, which triggers the actual request.
      return print_server_raw if env_truthy? "RAW"
      return print_error_response if response.error?

      call_slim_main(0)
    end
  end
end; end; end

#
# Implementation notes:
#
# * See `def request` for a cool testing hack: `@request || raise`.
#   It makes it possible to test abstract's class functionality without having to create successors
#   just to stub an attribute.
# * Column output order in all scripts is logical+alphabetical.
#   Most meaningful attributes are output first, the rest are loosely grouped based on decreasing
#   importance.
# * We deliberately don't use `OptionParser` in final scripts, using "meta-documented" env variables
#   instead. See `envar` and stuff.
# * `manifest` is an instance method to simplify its usage in output code. `self.class.manifest` is
#   clunky and thus less smart.
