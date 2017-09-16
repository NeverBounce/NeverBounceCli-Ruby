
require "never_bounce/cli/feature/eigencache"

module NeverBounce; module CLI
  # User's configuration values.
  # @see UserConfig::FileContent
  class UserConfig
    require_relative "user_config/file_content"

    CLI::Feature::BasicInitialize.load(self)
    CLI::Feature::Eigencache.load(self)

    attr_writer :api_key, :api_url

    # API key.
    # @return [String]
    def api_key
      @api_key ||= fc[:api_key]
    end

    # API URL.
    # @return [String]
    def api_url
      @api_url ||= fc[:api_url]
    end

    #---------------------------------------

    # @!attribute fc
    # @return [FileContent]
    def fc
      _cache[:fc] ||= FileContent.new
    end

    def fc=(obj)
      _cache[:fc] = obj
    end

    # "Touch" all attributes by loading them.
    # @return [self]
    def touch
      api_key; api_url
      self
    end
  end
end; end

#
# Implementation notes:
#
# * `api_url` has got no default here, it isn't a config responsibility.
