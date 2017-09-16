
require "never_bounce/cli/feature/basic_initialize"

module NeverBounce; module CLI; module Script
  # A short descriptive piece of information about the script.
  # @see CLI::Feature::BasicInitialize
  class Manifest
    CLI::Feature::BasicInitialize.load(self)

    # Script command-line options.
    # @return [String]
    attr_accessor :cmdline

    # Script function, one line.
    # @return [String]
    attr_accessor :function

    # Script name, as typed in a shell.
    # @return [String]
    attr_accessor :name
  end
end; end; end
