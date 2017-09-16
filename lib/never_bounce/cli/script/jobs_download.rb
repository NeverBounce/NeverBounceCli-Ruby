
require "neverbounce"

require "never_bounce/cli/script/feature/requires_job_id"

require_relative "request_maker"

module NeverBounce; module CLI; module Script
  class JobsDownload < RequestMaker
    Script::Feature::RequiresJobId.load(self)

    # An <tt>API::Request::JobsDownload</tt>.
    # @!attribute request
    # @return [Object]
    def request
      @request ||= API::Request::JobsDownload.new({
        api_key: api_key,
        job_id: job_id,
      })
    end

    #--------------------------------------- Manifest

    # @!attribute manifest
    # @return [Manifest]
    def manifest
      @manifest ||= Manifest.new(
        name: "nb-jobs-download",
        function: "Download job results as CSV",
        cmdline: "[options] [VAR1=value] [VAR2=value] ...",
      )
    end

    #--------------------------------------- Main

    # @return [Integer]
    def slim_main
      # Print CSV as is.
      stdout.puts server_raw

      0
    end
  end
end; end; end
