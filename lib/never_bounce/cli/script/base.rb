
require "shellwords"

require "never_bounce/cli/feature/basic_initialize"
require "never_bounce/cli/feature/require_attr"

module NeverBounce; module CLI; module Script
  # Barebones script base class.
  # @abstract
  # @see CLI::Feature::BasicInitialize
  # @see CLI::Feature::RequireAttr
  class Base
    CLI::Feature::BasicInitialize.load(self)
    CLI::Feature::RequireAttr.load(self)

    attr_writer :argv, :env, :stderr, :stdout

    # Command-line arguments. Default is <tt>ARGV</tt>.
    # @return [Array]
    def argv
      @argv ||= ARGV
    end

    # A *copy* of the environment for value-reading purposes. Default is <tt>ENV.to_h</tt>.
    # @!attribute env
    # @return [Hash]
    def env
      # Ruby's `ENV` is a weird thing.
      # It's a direct `Object` which acts like `Hash`.
      # It can't be reliably dup'd cloned, at the same time writes to it are invocation-global.
      # This implicit read/write nature of `ENV` is a major hassle in tests, since it creates unnecessary side effects we have to tackle with specifically.
      # Solution for now:
      #
      # 1. Since 99% of the time our script isn't interested in *writing* to ENV, this method deals with the READ case as the most widely used one.
      # 2. If we ever need to write to ENV in order to *create* the environment for a child process or something, we'll find a way to do it with grace.
      #
      # Everything above is a comment to `.to_h`, mysteriously present on the next line.
      @env ||= ENV.to_h
    end

    # Script's error stream. Default is <tt>STDERR</tt>.
    # @return [IO]
    def stderr
      @stderr ||= STDERR
    end

    # Script's output stream. Default is <tt>STDOUT</tt>.
    # @return [IO]
    def stdout
      @stdout ||= STDOUT
    end

    # <tt>true</tt> if the script should be verbose.
    # @return [true]
    def verbose?
      true
    end

    #--------------------------------------- Service

    # @see #env_truthy?
    def env_falsey?(k)
      !env_truthy?(k)
    end

    # Return <tt>true</tt> if environment variable <tt>k</tt> is truthy.
    #
    #   env_truthy? "WITH_HTTP"   # => `true` or `false`
    #   env_truthy? :WITH_HTTP    # same as above
    def env_truthy?(k)
      self.class.env_value_truthy?(env[k.to_s])
    end

    # Return <tt>true</tt> if environment variable value is truthy.
    #
    #   # These are truthy.
    #   DEBUG=1
    #   DEBUG=true
    #   DEBUG=y
    #   DEBUG=yes
    def self.env_value_truthy?(s)
      ["1", "true", "y", "yes"].include? s.to_s.downcase
    end

    # Run system command, print it if verbose.
    # @return [mixed] Result of <tt>Kernel.system</tt>.
    def system(cmd, *args)
      puts "### #{cmd} #{args.map(&:shellescape).join(' ')}" if verbose?
      Kernel.system(cmd, *args)
    end

    #---------------------------------------

    # Main routine.
    # @abstract
    # @return [Integer]
    def main
      raise NotImplementedError, "Redefine `main` in your class: #{self.class}"
    end
  end
end; end; end
