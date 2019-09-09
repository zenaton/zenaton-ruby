# frozen_string_literal: true

require 'zenaton/client'
require 'fixtures/version'
require 'fixtures/event'

RSpec.describe Zenaton::Client do
  let(:client) { described_class.instance }
  let(:http) do
    instance_double(
      Zenaton::Services::Http,
      post: nil,
      put: nil,
      get: workflow_data
    )
  end
  let(:graphql) do
    instance_double(
      Zenaton::Services::GraphQL::Client,
      schedule_task: nil,
      schedule_workflow: nil,
      start_task: nil,
      start_workflow: nil,
      kill_workflow: nil,
      pause_workflow: nil,
      resume_workflow: nil,
      send_event: nil,
      find_workflow: nil
    )
  end
  let(:workflow) { FakeWorkflow1.new(1, 2) }
  let(:task) { FakeTask3.new(1, 2) }
  let(:event) { FakeEvent.new }
  let(:version) { FakeVersion.new(1, 2) }
  let(:workflow_data) { { 'name' => 'Zenaton::Interfaces::Workflow' } }
  let(:uuid) { 'some-very-valid-uuid4' }
  let(:cron) { '* * * * * *' }
  let(:credentials) do
    {
      'app_id' => 'AppId',
      'api_token' => 'SecretToken',
      'app_env' => 'AppEnv'
    }
  end

  before do
    setup_client
  end

  describe '::init' do
    it 'sets the app id' do
      expect(client.instance_variable_get(:@app_id)).to eq('AppId')
    end

    it 'sets the api token' do
      expect(client.instance_variable_get(:@api_token)).to eq('SecretToken')
    end

    it 'sets the app environment' do
      expect(client.instance_variable_get(:@app_env)).to eq('AppEnv')
    end
  end

  describe 'initialization' do
    it 'there is only a single instance of the class' do
      client2 = described_class.instance
      expect(client).to eq(client2)
    end

    it 'cannot be initialized' do
      expect { described_class.new }.to \
        raise_error NoMethodError, /private method `new' called/
    end

    it 'stores an instance of the http service as an instance variable' do
      expect(client.instance_variable_get(:@http)).to eq(http)
    end

    it 'stores an instance of the graphql service as an instance variable' do
      expect(client.instance_variable_get(:@graphql)).to eq(graphql)
    end
  end

  describe '#worker_url' do
    context 'with environment variables but no instance variables set' do
      around do |example|
        ENV['ZENATON_WORKER_URL'] = 'http://192.168.1.1'
        ENV['ZENATON_WORKER_PORT'] = '42'
        example.run
        ENV.delete('ZENATON_WORKER_URL')
        ENV.delete('ZENATON_WORKER_PORT')
      end

      it 'returns the worker url with hash params' do
        url = client.worker_url('my_resource', 'myParam' => 1)
        expect(url).to \
          eq('http://192.168.1.1:42/api/v_newton/my_resource?myParam=1&app_env=AppEnv&app_id=AppId')
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'returns the worker url with string params' do
        expect do
          url = client.worker_url('my_resource', 'myParam=1')
          expect(url).to match(/myParam=1/)
        end.to output(/WARNING/).to_stderr
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    context 'with environment and instances variables set' do
      before { described_class.init('AppId', 'ApiToken', 'AppEnv') }

      around do |example|
        ENV['ZENATON_WORKER_URL'] = 'http://192.168.1.1'
        ENV['ZENATON_WORKER_PORT'] = '42'
        example.run
        ENV.delete('ZENATON_WORKER_URL')
        ENV.delete('ZENATON_WORKER_PORT')
      end

      it 'returns the worker url with app env' do
        url = client.worker_url('my_resource')
        expect(url).to \
          eq('http://192.168.1.1:42/api/v_newton/my_resource?app_env=AppEnv&app_id=AppId')
      end

      it 'encodes query params' do
        url = client.worker_url('my_resource', 'this+that' => '@')
        expect(url).to match(/this%2Bthat=%40/)
      end
    end

    context 'with instances variables but no environment variables set' do
      before { described_class.init('AppId', 'ApiToken', 'AppEnv') }

      it 'returns the default worker url with app env' do
        url = client.worker_url('my_resource')
        expect(url).to \
          eq('http://localhost:4001/api/v_newton/my_resource?app_env=AppEnv&app_id=AppId')
      end

      it 'encodes query params' do
        url = client.worker_url('my_resource', 'this+that' => '@')
        expect(url).to match(/this%2Bthat=%40/)
      end
    end

    context 'with no environment nor instances variables set' do
      it 'returns the default worker url' do
        url = client.worker_url('my_resource')
        expect(url).to \
          eq('http://localhost:4001/api/v_newton/my_resource?app_env=AppEnv&app_id=AppId')
      end

      it 'encodes query params' do
        url = client.worker_url('my_resource', 'this+that' => '@')
        expect(url).to match(/this%2Bthat=%40/)
      end
    end
  end

  describe '#website_url' do
    before { described_class.init('AppId', 'ApiToken', 'AppEnv') }

    context 'with environment variables set' do
      around do |example|
        ENV['ZENATON_API_URL'] = 'http://192.168.1.1'
        example.run
        ENV.delete('ZENATON_API_URL')
      end

      it 'returns the website url with api token' do
        url = client.website_url('my_resource')
        expect(url).to \
          eq('http://192.168.1.1/my_resource?api_token=ApiToken&app_env=AppEnv&app_id=AppId')
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'returns the worker url with string params' do
        expect do
          url = client.website_url('my_resource', 'param=1')
          expect(url).to match(/param=1/)
        end.to output(/WARNING/).to_stderr
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'urlencodes hash params' do
        url = client.website_url('my_resource', 'this+that' => '@')
        expect(url).to match(/this%2Bthat=%40/)
      end
    end

    context 'with no environment variables set' do
      it 'returns the default website url api token' do
        url = client.website_url('my_resource')
        expect(url).to \
          eq('https://api.zenaton.com/v1/my_resource?api_token=ApiToken&app_env=AppEnv&app_id=AppId')
      end

      it 'encodes query params' do
        url = client.website_url('my_resource', 'this+that' => '@')
        expect(url).to match(/this%2Bthat=%40/)
      end
    end
  end

  describe '#start_task' do
    let(:start_task) { client.start_task(task) }

    before { start_task }

    it 'delegates to the graphql client' do
      expect(graphql).to \
        have_received(:start_task)
        .with(task, credentials)
    end
  end

  describe '#start_workflow' do
    let(:start_workflow) { client.start_workflow(workflow) }
    let(:start_version_workflow) { client.start_workflow(version) }
    let(:expected_url) { 'http://localhost:4001/api/v_newton/instances?' }
    let(:expected_hash) do
      {
        'intent_id' => uuid,
        'programming_language' => 'Ruby',
        'canonical_name' => nil,
        'name' => 'FakeWorkflow1',
        'data' => {
          'o' => '@zenaton#0',
          's' => [{ 'a' => { :@first => 1, :@second => 2 } }]
        }.to_json,
        'custom_id' => nil
      }
    end

    it 'delegates to the graphql client' do
      start_version_workflow
      expect(graphql).to \
        have_received(:start_workflow)
        .with(version, credentials)
    end
  end

  describe '#start_scheduled_workflow' do
    context 'with a valid workflow' do
      it 'calls the graphQL request' do
        client.start_scheduled_workflow(workflow, cron)
        expect(graphql).to \
          have_received(:schedule_workflow)
          .with(workflow, cron, credentials)
      end
    end

    context 'with a valid version workflow' do
      it 'calls the graphQL request' do
        client.start_scheduled_workflow(version, cron)
        expect(graphql).to \
          have_received(:schedule_workflow)
          .with(version, cron, credentials)
      end
    end
  end

  describe '#start_scheduled_task' do
    context 'with a valid workflow' do
      it 'calls the graphQL request' do
        client.start_scheduled_task(task, cron)
        expect(graphql).to \
          have_received(:schedule_task)
          .with(task, cron, credentials)
      end
    end
  end

  describe '#kill_workflow' do
    before { client.kill_workflow('MyWorkflow', 'MyCustomId') }

    it 'delegates to the graphql client' do
      expect(graphql).to \
        have_received(:kill_workflow)
        .with('MyWorkflow', 'MyCustomId', credentials)
    end
  end

  describe '#pause_workflow' do
    before { client.pause_workflow('MyWorkflow', 'MyCustomId') }

    it 'delegates to the graphql client' do
      expect(graphql).to \
        have_received(:pause_workflow)
        .with('MyWorkflow', 'MyCustomId', credentials)
    end
  end

  describe '#resume_workflow' do
    before { client.resume_workflow('MyWorkflow', 'MyCustomId') }

    it 'delegates to the graphql client' do
      expect(graphql).to \
        have_received(:resume_workflow)
        .with('MyWorkflow', 'MyCustomId', credentials)
    end
  end

  describe '#find_workflow' do
    before do
      client.find_workflow('FakeWorkflow1', 'MyCustomId')
    end

    it 'delegates to the graphql client' do
      expect(graphql).to \
        have_received(:find_workflow)
        .with('FakeWorkflow1', 'MyCustomId', credentials)
    end
  end

  describe '#send_event' do
    before { client.send_event('MyWorkflow', 'MyCustomId', event) }

    it 'delegates to the graphql client' do
      expect(graphql).to \
        have_received(:send_event)
        .with('MyWorkflow', 'MyCustomId', event, credentials)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def setup_client
    Singleton.__init__(described_class)
    allow(Zenaton::Services::Http).to receive(:new).and_return(http)
    allow(Zenaton::Services::GraphQL::Client).to \
      receive(:new).and_return(graphql)
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    described_class.init(*credentials.values)
  end
  # rubocop:enable Metrics/AbcSize
end
