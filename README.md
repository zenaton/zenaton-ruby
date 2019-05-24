<p align="center">
<img src="https://user-images.githubusercontent.com/36400935/58254828-e5176880-7d6b-11e9-9094-3f46d91faeee.png" /><br>
  Easy Asynchronous Jobs Manager for Developers <br>
  <a href="https://zenaton.com/documentation/ruby/getting-started/">
    <strong> Explore the docs » </strong>
  </a> <br>
  <a href="https://zenaton.com"> Website </a>
     ·
  <a href="https://github.com/zenaton/examples-ruby"> Examples in Ruby </a>
   ·
  <a href="https://app.zenaton.com/tutorial/ruby"> Tutorial in Ruby </a>

  <p align="center">
  <a href="https://rubygems.org/gems/zenaton"><img src="https://img.shields.io/gem/v/zenaton.svg" alt="Gem Version"></a>
  <a href="https://circleci.com/gh/zenaton/zenaton-ruby/tree/master" rel="nofollow" target="_blank"><img src="https://img.shields.io/circleci/project/github/zenaton/zenaton-ruby/master.svg" alt="CircleCI" style="max-width:100%;"></a>
  <a href="/LICENSE" target="_blank"><img src="https://img.shields.io/github/license/zenaton/zenaton-ruby.svg" alt="License" style="max-width:100%;"></a>
</p>
</p>

<details>
  <summary><strong>Table of contents</strong></summary>

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Installation](#installation)
- [Setup with Ruby on Rails](#setup-with-ruby-on-rails)
  - [Client initialization](#client-initialization)
  - [Worker Installation](#worker-installation)
- [Setup with plain Ruby](#setup-with-plain-ruby)
  - [Client Initialization](#client-initialization)
  - [Worker Installation](#worker-installation-1)
- [Usage](#usage)
  - [Writing a task](#writing-a-task)
  - [Writing a workflow](#writing-a-workflow)
  - [Lauching a workflow](#lauching-a-workflow)
- [Documentation](#documentation)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

</details>

## Getting Started

### Requirements

This gem has been tested with Ruby 2.3 and later.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'zenaton'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zenaton

## Setup with Ruby on Rails

### Client initialization

1. Create an initializer in `config/initializers/zenaton.rb` with the following:

```ruby
Zenaton::Client.init(
  ENV['ZENATON_APP_ID'],
  ENV['ZENATON_API_TOKEN'],
  ENV['ZENATON_APP_ENV']
)
```

2. Add a `.env` file at the root of your project with [your credentials](https://app.zenaton.com/api):

```
ZENATON_API_URL=...
ZENATON_APP_ID=...
ZENATON_API_TOKEN=...
```

Don't forget to add it to your `.gitignore`:

```bash
$ echo ".env" >> .gitignore
```

3. Add the [dotenv gem](https://github.com/bkeepers/dotenv) to your `Gemfile` to easily load these variables in development:

```ruby
gem 'dotenv-rails', groups: [:development, :test]
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

Your are now ready to [write tasks and workflows](#usage) !

## Setup with plain Ruby

### Client Initialization

You will need to export three environment variables: `ZENATON_APP_ID`, `ZENATON_API_TOKEN`, `ZENATON_APP_ENV`. You'll find them [here](https://app.zenaton.com/api).

Then you can initialize your Zenaton client:

```ruby
require 'dotenv/load'
require 'zenaton'

Zenaton::Client.init(
  ENV['ZENATON_APP_ID'],
  ENV['ZENATON_API_TOKEN'],
  ENV['ZENATON_APP_ENV']
)
```

### Worker Installation

Your workflow's tasks will be executed on your worker servers. Please install a Zenaton worker on it:

    $ curl https://install.zenaton.com | sh

that you can start and configure with

    $ zenaton start && zenaton listen --env=.env --boot=boot.rb

where `.env` is the env file containing [your credentials](https://app.zenaton.com/api), and `boot.rb` is a file that will be included before each task execution - this file should load all workflow classes.

## Usage

For more detailed examples, please check [Zenaton Ruby examples](https://github.com/zenaton/examples-ruby).

### Writing a task

```ruby
class MyTask < Zenaton::Interfaces::Task
  include Zenaton::Traits::Zenatonable

  def handle
    # Your task implementation
  end
end
```

[Check the documentation for more details.](https://zenaton.com/documentation/ruby/tasks)

### Writing a workflow

```ruby
class MyWorkflow < Zenaton::Interfaces::Workflow
  include Zenaton::Traits::Zenatonable

  def handle
    # Your workflow implementation
  end
end
```

Note that your workflow implementation should be idempotent.

With Ruby on Rails, you may need to run `$ spring stop` to force Spring to load your app fresh.

[Check the documentation for more details.](https://zenaton.com/documentation/ruby/workflow-basics)

### Lauching a workflow

We can start a workflow from anywhere in our application code with:

```ruby
MyWorkflow.new.dispatch
```

## Documentation

Please see https://zenaton.com/documentation/ruby/getting-started for complete documentation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zenaton/zenaton-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the zenaton-ruby project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zenaton/zenaton-ruby/blob/master/CODE_OF_CONDUCT.md).
