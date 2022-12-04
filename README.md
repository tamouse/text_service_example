# TextServiceExam0le

This is a coding example for creating a texting feature in a Rails app. It's only about the feature here, but normally this would be added to an existing app.

My approach is to design the controller actions and models to perform the flow of a text message request coming in, getting handed over to text message service provider, and tracking successes, failures, errors, and the like, as well as providing a rudimentary load balancing between the providers.

The specifications are difined in the problem description, and I won't necessarily repeat any more.

## Dependencies

The typical dependencies for a modern Rails project

- Redis (on a Mac, install with HomeBrew)
- Ruby 3.1.1
- Bundler 2.3.7
- Rails 7.0.4

Other dependencies are handled by the Gemfile and package.json.

To get everything in order, run:

    $ bundle install
    $ yarn install 
    
## Databases

For practicality I decided to implement using SQLite instead of Postgresql or MySQL. As it's only going to need to handle a tiny number of messages, it should be fine for demo purposes.

Stand up the database for the first time with:

    $ rails db:migrate
    $ rails db:fixtures:load

The following will tear down the databases and reset everything:

    $ rails db:migrate:reset
    $ rails db:fixtures:load

*(Good when you're futzing with migrations, or mess up the data somehow.)*


## Testing

I chose to use Minitest and ActiveSupport::TestCase to keep testing fast and simple. I'm also following a philosophy for testing in the demo to test only code written for the demo, and not deal with verifying everything else one might do with models, controllers, services, libraries, and the like.

Run tests with:

    $ rails test
    
### Live testing ###

This is for doing some live testing where you don't want the VCR cassettes to get in your way.

From the command line, hit the send API from `curl`:

``` shell
curl -is -X POST \
     -H 'Content-type: application/json' \
     -d '{"phone_number":"8005551212","message_body":"a message from curl"}' \
     'http://localhost:3000/api/v1/send.json'
```

From the Rails console (pry) :

``` ruby
# Create a phone, then a message
p = Phone.create(number: "8005551212", status: "active")
m = Message.create(phone_id: p.id, message_body: "a message from rails console", status: "sending")

# Create a service instance
s = SendMessageService.new(message: m)

# Send the message
s.send!

# Explore the result
s.client.result
```

## Development

In the mode of keeping things simple, testable, and easy to develop, I've forgone some niceties. There's virtually no front end to the app, except to see a list of messages, and as mini-page app to fire off a new text message request in the background to the API.

## Archicture

### Flow Diagram

Just a rough sketch of the flow of information through this app.

![Process flow diagram showing how data and control move through the feature subsystem](./app/assets/images/flow-diagram.jpg "Flow Diagram")

1. Agent "A" posts a request to the API endpoint to create a message and send it to the provider
2. The provider replies and the response is used to update the message
3. The provider sends a post request to the web hook endpoint that includes the message ID returned earlier and the status of the message delivery.
4. The message is updated with the information, and if the max number of tries are exceeded, fails the message completely

There are other tracking mechanisms in play as well to monitor and adjust the feature's behaviour based on the responses and web hooks from the provider.

### Models Diagram

Original diagram:

![A diagram of the models used in thiw feature and their relationship to each other](./app/assets/images/model_diagram.jpg "Model Diagram")

Final diagram:

![An updated diagram of the models used in thiw feature and their relationship to each other](./app/assets/images/model-diagram-updated.jpg "Update Model Diagram")

1. `User` holds just enough information to validate the API request using HTTP Basic auth. For the demo, there's only one user.
2. `Message` contains the message id and body, as well as the key of the phone number.
4. `Phone` holds the  phone number for a requested measure, as well as status, validity.
6. `Provider` contains the information needed to interact with providers and keep errors, statistics, and status.
7. `ActivityLog` contains more detailed information about each use of `Phone`, `Message`, and `Provider`

### Services Classes

To keep both controllers and persistence models thin, I'm using service classes that perform the logic of the application.

### Libraries

To isolate the interface with the service providers, I'm using a library to generalize the interface for calling the providers, which allows for delete-ability / replacement.

#### provider_api

The library was initialized with `bundle gem provider_api` in the `./lib/` directory. The `.git` directory was removed so it would all be in the same repo. 

The library has it's own [README file](./lib/provider_api/README.md "README for provider_api library")

The ruby gem structure is great for adding internal libraries as it provides a familiar structure and just removes the problem of figuring out how to do that. There are some tricky bits to make it work properly with the whole app.

##### Gemfile

The `Gemfile` needs an entry to the library to treat it as a valid gem when running `bundle install`:

file `'./Gemfile'`:
``` ruby
gem 'provider_api', path: './lib/provider_api/'
```

