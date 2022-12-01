# ProviderApi

An "internal" library gem that handles the communication with the providers

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'provider_api', path: File.expand_path('../lib/provider_api/', __FILE__)
```

And then execute:

    $ bundle install

## Usage

@TODO: Write up a manual for using the API 

## Development

Instead of writing tests in the gem directly, it's easier to write them in the parent app's testing directory. If you later decide to release the library separately, the tests should move with little change. CAVEAT: in the tests, do not rely on `Rails` or any of it components.

The "main" library file in `./lib/provider_api.rb` is a tricky thing that allows all the pieces of the library to be loaded up at run time using the same loader Rails uses. These are `require`d directly, and also included in the gem's `Gemfile` although they aren't loaded from there when included in the parent rails app. It's pretty cool.

See [Add code auto-loading to a Ruby project with Zeitwerk](https://thurlow.io/ruby/2019/11/17/add-code-auto-loading-to-a-ruby-project-with-zeitwerk.html "A nice way to use autoloading in plain old Ruby gems like Rails does!")

