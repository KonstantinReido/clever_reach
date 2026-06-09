require_relative "lib/clever_reach/version"

Gem::Specification.new do |spec|
  spec.name = "clever_reach"
  spec.version = CleverReach::VERSION
  spec.authors = ["Konstantin Reido"]
  spec.email = ["konstantin.reido@gmail.com"]

  spec.summary = "Ruby wrapper for CleverReach API"
  spec.description = "A Ruby gem that provides a convenient wrapper for the CleverReach REST API using Client Credentials authentication."
  spec.homepage = "https://github.com/KonstantinReido/clever_reach"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ debug/ test/ spec/ features/ .git .github .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # No external dependencies needed - uses standard library Net::HTTP

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "irb"
  spec.add_development_dependency "rdoc"
end
