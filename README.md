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

## Testing

I chose to use Minitest and ActiveSupport::TestCase to keep testing fast and simple. I'm also following a philosophy for testing in the demo to test only code written for the demo, and not deal with verifying everything else one might do with models, controllers, services, libraries, and the like.

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

![A diagram of the models used in thiw feature and their relationship to each other](./app/assets/images/model_diagram.jpg "Model Diagram")


