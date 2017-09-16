
require "yaml"

require "never_bounce/cli/feature/basic_initialize"

require_relative "../user_config"

module NeverBounce; module CLI; class UserConfig
  # User's configuration file content.
  # @see #filename
  # @see UserConfig
  # @see CLI::Feature::BasicInitialize
  class FileContent
    CLI::Feature::BasicInitialize.load(self)

    attr_writer :body, :body_hash, :env, :filename

    # YAML configuration, source text.
    # @!attribute body
    # @return [String]
    def body
      @body ||= begin
        File.read(filename)
      rescue Errno::ENOENT    # Missing file is okay, let other exceptions manifest.
        ""
      end
    end

    # YAML configuration, parsed.
    # @!attribute body_hash
    # @return [Hash]
    def body_hash
      @body_hash ||= body.to_s.empty?? {} : YAML.load(body)
    end

    # A copy of environment for read purposes. Default is <tt>ENV.to_h</tt>.
    # @return [Hash]
    def env
      @env ||= ENV.to_h
    end

    # Configuration filename. Default is <tt>$HOME/.neverbounce.yml</tt>.
    # @return [String]
    def filename
      @filename ||= File.join(env["HOME"], ".neverbounce.yml")
    end

    #---------------------------------------

    # Fetch a value.
    #
    #   config_file["api_key"]
    #   config_file[:api_key]   # Same as above.
    def [](k)
      body_hash[k.to_s]
    end

    # <tt>true</tt> if key is set.
    #
    #   has_key?("api_key")
    #   has_key?(:api_key)      # Identical to the previous one.
    def has_key?(k)
      body_hash.has_key? k.to_s
    end
  end
end; end; end
