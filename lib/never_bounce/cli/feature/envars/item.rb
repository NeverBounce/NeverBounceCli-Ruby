
require "never_bounce/cli/feature/basic_initialize"
require "never_bounce/cli/feature/igetset"

require_relative "../envars"

module NeverBounce; module CLI; module Feature; module Envars
  # Single envar item container.
  class Item
    CLI::Feature::BasicInitialize.load(self)
    CLI::Feature::Igetset.load(self)

    # @return [String]
    attr_accessor :name

    # @return [String]
    attr_accessor :comment

    attr_writer :default, :examples, :is_mandatory

    # Default value. Default is <tt>nil</tt>.
    # @return [mixed]
    def default
      igetset(:default) { nil }
    end

    # Value examples. Default is <tt>[]</tt>.
    # @return [Array]
    def examples
      @examples ||= []
    end

    # True if this envar is mandatory. Default is <tt>false</tt>.
    # @return [bool]
    def is_mandatory
      igetset(:is_mandatory) { false }
    end

    alias_method :mandatory?, :is_mandatory
  end
end; end; end; end
