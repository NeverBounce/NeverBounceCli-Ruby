
require "never_bounce/cli/feature/basic_initialize"

require_relative "../jobs_create"

module NeverBounce; module CLI; module Script; class JobsCreate
  # The parser for <tt>SUPPLIED_INPUT=</tt> environment variable.
  # @see #process
  # @see CLI::Feature::BasicInitialize
  class SuppliedInputParser
    CLI::Feature::BasicInitialize.load(self)

    attr_writer :separator

    # @return [Regexp]
    def separator
      @separator ||= /[;,\n]/
    end

    #---------------------------------------

    # Process content, return parsed structure.
    #
    # NOTE: The parser doesn't validate e-mail addresses.
    #
    #   process("tom@isp.com Tom User;dick@gmail.com Dick Other")
    #   # => [["tom@isp.com", "Tom User"], ["dick@gmail.com", "Dick Other"]]
    #
    # @return [Array<email, name>]
    def process(content)
      # NOTE: Keep it stage-procedural for easier debugging.
      chunks = content.split(separator).map(&:strip).reject(&:empty?)

      out = chunks.map do |chunk|
        if (chunk =~ /^(.+?)\s+(.+)$/)
          [$1, $2]
        else
          [chunk, ""]
        end
      end

      out.empty? and raise ArgumentError, "Empty content"

      out
    end
    alias_method :[], :process
  end
end; end; end; end
