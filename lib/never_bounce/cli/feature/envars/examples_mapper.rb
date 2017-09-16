
require_relative "../envars"

module NeverBounce; module CLI; module Feature; module Envars
  # A simple transformer/validator for <tt>examples</tt> argument.
  #
  # @see #process
  class ExamplesMapper
    # Process input, render output.
    #
    #   process([1, 2, 3])            # => {values: [1, 2, 3]}
    #   process([1, 2, default: 3])   # => {values: [1, 2, 3], default: 3}
    #
    # @param input [Array] Items to process.
    # @return [Hash] A hash with <tt>values</tt> and optionally <tt>default</tt>.
    def process(input)
      values, default = [], nil

      input.each do |elem|
        if elem.is_a? Hash
          # Validate, then use.
          raise ArgumentError, "Unknown element format: #{elem.inspect}" if elem.keys != [:default]
          values << (default = elem[:default])
        else
          values << elem
        end
      end

      # Return result.
      {}.tap do |h|
        h[:values] = values
        h[:default] = default if default
      end
    end

    alias_method :[], :process
  end
end; end; end; end
