
# Optionally include developer-local spec helper.
File.readable?(fn = File.join(__dir__, "spec_local.rb")) and require fn

# Start SimpleCov if it's enabled in Gemlocal.
begin
  require "simplecov"
  puts "NOTE: SimpleCov starting"
  SimpleCov.start
rescue LoadError
  # This is mostly a normal case, don't print anything.
end

# Self.
require "neverbounce-cli"

# Require all `spec_helper.rb` throughout the tree for shared contexts.
Dir[File.join(__dir__, "**/spec_helper.rb")].each { |fn| require fn }

RSpec.configure do |conf|
  conf.extend Module.new {
    # Include hierarchical contexts from <tt>spec/</tt> up to <tt>__dir__</tt>.
    #
    #   describe Something do
    #     include_dir_context __dir__
    #     ...
    def include_dir_context(dir)
      d, steps = dir, []
      while d.size >= __dir__.size
        steps << d
        d = File.join(File.split(d)[0..-2])
      end

      steps.reverse.each do |d|
        begin; include_context d; rescue ArgumentError; end
      end
    end
  } # conf.extend
end

# Absolutely common shared context.
shared_context __dir__ do
  shared_examples "instantiatable" do
    it { expect(described_class.new).to be_a described_class }
  end

  # General-purpose "create new object".
  def newo(attrs = {})
    described_class.new(attrs)
  end
end
