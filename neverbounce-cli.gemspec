
require_relative "lib/never_bounce/cli/version"

Gem::Specification.new do |s|
  s.name = "neverbounce-cli"
  s.summary = "The official NeverBounce CLI written in Ruby"

  s.authors = ["NeverBounce"]
  s.email = ["support@neverbounce.com"]
  s.homepage = "https://neverbounce.com"
  s.license = "MIT"
  s.version = NeverBounce::CLI::VERSION

  s.required_ruby_version = ">= 2.0.0"

  s.bindir = "exe"
  s.executables = `git ls-files -- exe/*`.split("\n").map { |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency("neverbounce-api", "~> 1.0.0")
  s.add_dependency("terminal-table", "~> 1.8.0")
end
