# Zenaton library for Ruby
[![CircleCI](https://circleci.com/gh/zenaton/zenaton-ruby/tree/master.svg?style=svg&circle-token=99da357820821f49236b1e2f20657100fb382bd8)](https://circleci.com/gh/zenaton/zenaton-ruby/tree/master)

This Zenaton library for Ruby lets you code and launch workflows using Zenaton platform. You can sign up for an account at [https://zenaton/com](http://zenaton.com)

## Requirements

This gem has been tested with Ruby 2.3 or later.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zenaton'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zenaton

## Usage

For more detailed examples, please check [Zenaton Ruby examples](https://github.com/zenaton/example-ruby).

### Client Initialization

You will need to export three environment variables: `ZENATON_APP_ID`, `ZENATON_API_TOKEN`, `ZENATON_APP_ENV`. You'll find them [here](https://zenaton/app/api).

Then you can initialize your Zenaton client:
```ruby
require 'dotenv/load' # We are using dotenv to load the variables from a .env file
require 'zenaton'

app_id = ENV['ZENATON_APP_ID']
api_token = ENV['ZENATON_API_TOKEN']
app_env = ENV['ZENATON_APP_ENV']

Zenaton::Client.init(app_id, api_token, app_env)
```

### Writing Workflows and Tasks

Writing a workflow is as simple as:

```ruby
class MyWorkflow < Zenaton::Interfaces::Worflow
  include Zenatonable

  def handle
    # Your workflow implementation
  end
end
```
Note that your workflow implementation should be idempotent. See [documentation](https://zenaton.com/app/documentation#workflow-basics-implementation).

Writing a task is as simple as:
```ruby
class MyTask < Zenaton::Interfaces::Task
  include Zenatonable

  def handle
    # Your task implementation
  end
end
```

### Launching a workflow

Once your Zenaton client is initialized, you can start a workflow with

```ruby
MyWorkflow.new.dispatch
```

### Worker Installation

Your workflow's tasks will be executed on your worker servers. Please install a Zenaton worker on it:
```
curl https://install.zenaton.com | sh
```

that you configure with
```
zenaton listen --env=.env --boot=boot.rb
```

where `.env` is the env file containing your credentials, and `boot.rb` is a file that will be included before each task execution = this file should load all workflow classes.

## Documentation

Please see https://zenaton.com/documentation for complete documentation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zenaton/zenaton-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the zenaton-ruby project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zenaton/zenaton-ruby/blob/master/CODE_OF_CONDUCT.md).
