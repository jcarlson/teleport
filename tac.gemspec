# frozen_string_literal: true

require_relative "lib/tac/version"

Gem::Specification.new do |spec|
  spec.name          = "tac"
  spec.version       = TAC::VERSION
  spec.authors       = ["Jarrod Carlson"]
  spec.email         = ["jarrod.carlson@gmail.com"]

  spec.summary       = "Teleport Automation Challenge (tac)"
  spec.description   = "Automates detection and mitigation of port scanning"
  spec.homepage      = "https://github.com/jcarlson/teleport"
  spec.required_ruby_version = ">= 3.0.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://raw.githubusercontent.com/jcarlson/teleport/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "packetfu", "~> 1.1"
  spec.add_dependency "prometheus-client", "~> 2.1"
  spec.add_dependency "rack", "~> 2.2"
  spec.add_dependency "thin", "~> 1.8"
  spec.add_dependency "thor", "~> 1.1"

  spec.add_development_dependency "aruba", "~> 1.1"
  spec.add_development_dependency "cucumber", "~> 6.1"
  spec.add_development_dependency "timecop", "~> 0.9"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
