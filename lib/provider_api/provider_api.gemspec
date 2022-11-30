# frozen_string_literal: true

require_relative "lib/provider_api/version"

Gem::Specification.new do |spec|
  spec.name = "provider_api"
  spec.version = ProviderApi::VERSION
  spec.authors = ["Tamara Temple"]
  spec.email = ["tamouse@gmail.com"]

  spec.summary = "API to text service providers"
  spec.homepage = "https://github.com/tamouse/text_service_example"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
