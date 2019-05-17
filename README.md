# Zenaton library for Ruby
[![Gem Version](https://img.shields.io/gem/v/zenaton.svg)](https://rubygems.org/gems/zenaton)
[![Gem Downloads](https://img.shields.io/gem/dt/zenaton.svg)](https://rubygems.org/gems/zenaton)
[![CircleCI](https://img.shields.io/circleci/project/github/zenaton/zenaton-ruby/master.svg)](https://circleci.com/gh/zenaton/zenaton-ruby/tree/master)
[![License](https://img.shields.io/github/license/zenaton/zenaton-ruby.svg)](LICENSE.txt)

This Zenaton library for Ruby lets you code and launch workflows using Zenaton platform. You can sign up for an account at [https://zenaton.com](http://zenaton.com)

## Requirements

This gem has been tested with Ruby 2.3 and later.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zenaton'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zenaton

## Usage in plain Ruby

For more detailed examples, please check [Zenaton Ruby examples](https://github.com/zenaton/examples-ruby).

### Client Initialization

You will need to export three environment variables: `ZENATON_APP_ID`, `ZENATON_API_TOKEN`, `ZENATON_APP_ENV`. You'll find them [here](https://app.zenaton.com/api).

Then you can initialize your Zenaton client:
```ruby
require 'dotenv/load' # We are using dotenv to load the variables from a .env file
require 'zenaton'

Zenaton::Client.init(
  ENV['ZENATON_APP_ID'], 
  ENV['ZENATON_API_TOKEN'], 
  ENV['ZENATON_APP_ENV']
)
```

### Writing Workflows and Tasks

Writing a workflow is as simple as:

```ruby
class MyWorkflow < Zenaton::Interfaces::Workflow
  include Zenaton::Traits::Zenatonable

  def handle
    # Your workflow implementation
  end
end
```
Note that your workflow implementation should be idempotent. See [documentation](https://zenaton.com/documentation/ruby/workflow-basics#implementation).

Writing a task is as simple as:
```ruby
class MyTask < Zenaton::Interfaces::Task
  include Zenaton::Traits::Zenatonable

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

    $ curl https://install.zenaton.com | sh

that you can start and configure with

    $ zenaton start && zenaton listen --env=.env --boot=boot.rb

where `.env` is the env file containing [your credentials](https://app.zenaton.com/api), and `boot.rb` is a file that will be included before each task execution - this file should load all workflow classes.

## Usage inside a Ruby on Rails application

### Client initialization
1) Create an initializer in `config/initializers/zenaton.rb` with the following:
```ruby
Zenaton::Client.init(
  ENV['ZENATON_APP_ID'], 
  ENV['ZENATON_API_TOKEN'], 
  ENV['ZENATON_APP_ENV']
)
```

2) Add a `.env` file at the root of your project with [your credentials](https://app.zenaton.com/api):
```
ZENATON_API_URL=...
ZENATON_APP_ID=...
ZENATON_API_TOKEN=...
```
Don't forget to add it to your `.gitignore`:
```
.env
```

3) Add the [dotenv gem](https://github.com/bkeepers/dotenv) to your `Gemfile` to load these variables in development:
```ruby
gem 'dotenv-rails', groups: [:development, :test]
``` 

### Writing Workflows and Tasks

We can create a workflow in `app/workflows/my_workflow.rb`.

```ruby
class MyWorkflow < Zenaton::Interfaces::Workflow
  include Zenaton::Traits::Zenatonable

  def handle
    # Your workflow implementation
  end
end
```
Note that your workflow implementation should be idempotent. See [documentation](https://zenaton.com/app/documentation#workflow-basics-implementation).

And we can create a task in `app/tasks/my_task.rb`.
```ruby
class MyTask < Zenaton::Interfaces::Task
  include Zenaton::Traits::Zenatonable

  def handle
    # Your task implementation
  end
end
```
Note that you may need to run `$ spring stop` to force Spring to load your app fresh.

### Lauching a workflow

We can start a workflow from anywhere in our application code with:
```ruby
MyWorkflow.new.dispatch
```

### Worker Installation

Your workflow's tasks will be executed on your worker servers. Please install a Zenaton worker on it:

    $ curl https://install.zenaton.com | sh

that you can start and configure from your application directory with

    $ zenaton start && zenaton listen --env=.env --rails

where `.env` is the env file containing [your credentials](https://app.zenaton.com/api).

**Note** In this example we created our workflows and tasks in the `/app`
folder since Rails will autoload ruby files in that path. If you create your
workflows and tasks somewhere else, ensure Rails loads them at boot time.

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
