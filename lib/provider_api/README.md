# ProviderApi

An "internal" library gem that handles the communication with the providers

## Installation

The "main" library file in `./lib/provider_api.rb` is a tricky thing that allows all the pieces of the library to be loaded up at run time using the same loader Rails uses.

To get the library effectively loaded in the Rails app, add this line to the application's Gemfile:

```ruby
gem 'provider_api', path: File.expand_path('../lib/provider_api/', __FILE__)
```

And then run from the command line:

    $ bundle install

## Usage

The API for the client is quit simple. The initialization takes the static parts for this client, i.e. the endpoint to call, and the callback endpoint for the provider to return info to the app on. The only public instance method is the `post` method, which accepts the message fields required by the provider service.

### Initialization ###

``` ruby
@client = ProviderApi::Client.new(endpoint: Provider.first.endpoint, callback: 'https://example.ngrok.io/delivery_status')
```


### Posting ###

Using the client from before:

``` ruby
@client.post(phone_number: '9991234567', message_body: 'on my way')
```

## Development

Instead of writing tests in the gem directly, it's easier to write them in the parent app's testing directory. If you later decide to release the library separately, the tests should move with little change. CAVEAT: in the tests, do not rely on `Rails` or any of it components.

See [Add code auto-loading to a Ruby project with Zeitwerk](https://thurlow.io/ruby/2019/11/17/add-code-auto-loading-to-a-ruby-project-with-zeitwerk.html "A nice way to use autoloading in plain old Ruby gems like Rails does!")

