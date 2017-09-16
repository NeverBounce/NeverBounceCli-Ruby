
module NeverBounce; module CLI; module Feature
  # Declare and manage environment variables of the class.
  module Envars
    require_relative "envars/examples_mapper"
    require_relative "envars/item"

    # @param owner [Class]
    # @return [nil]
    def self.load(owner)
      return if owner < InstanceMethods
      owner.extend(ClassMethods)
      owner.send(:include, InstanceMethods)
    end

    module ClassMethods
      attr_writer :envars

      def envars
        @envars ||= if superclass.respond_to? :envars
          superclass.envars.dup
        else
          []
        end
      end

      #---------------------------------------
      private

      # Define an envar in a formal way.
      # @param name [String]
      # @param comment [String]
      # @return [Item]
      def define_envar(name, comment, is_mandatory: false, examples: [], default: nil)
        Item.new({
          name: name,

          comment: comment,
          default: default,
          examples: examples,
          is_mandatory: is_mandatory,
        }).tap { |_| envars << _ }
      end

      # Declare an envar in a concise and magical way.
      #
      #   envar "ID", "Job ID"
      #   => define_envar "ID", "Job ID"
      #   envar "API_KEY*", "API key", ["2ed45186c72f9319dc64338cdf16ab76b44cf3d1"]
      #   # => define_envar "API_KEY", "API key", is_mandatory: true, examples: [...]
      #   envar "RAW", "Print raw response body", ["y", default: "N"]
      #   # => define_envar "RAW", "Print raw response body", examples: ["y", "N"], default: "N"
      def envar(name, comment, examples = [])
        options = {}

        real_name = if name[-1] == "*"
          options[:is_mandatory] = true
          name[0..-2]
        else
          name
        end

        if not examples.empty?
          h = ExamplesMapper.new[examples]
          options[:examples] = h[:values]
          options[:default] = h[:default] if h.include?(:default)
        end

        define_envar(real_name, comment, options)
      end
    end

    module InstanceMethods
    end
  end
end; end; end

#
# Implementation notes:
#
# * `envars` belongs to the class, but considering its superclasses.
#   We don't use @@var to avoid unnecessary side effect.
