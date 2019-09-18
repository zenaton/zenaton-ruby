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
      Zenaton::Services::GraphQL,
      request: nil
    )
  end
  let(:workflow) { FakeWorkflow1.new(1, 2) }
  let(:task) { FakeTask3.new(1, 2) }
  let(:event) { FakeEvent.new }
  let(:version) { FakeVersion.new(1, 2) }
  let(:workflow_data) { { 'name' => 'Zenaton::Interfaces::Workflow' } }
  let(:uuid) { 'some-very-valid-uuid4' }
  let(:cron) { '* * * * * *' }

  before do
    setup_client
  end

  describe '::init' do
    let(:instance) { described_class.init('AppId', 'SecretToken', 'AppEnv') }

    before { instance }

    it 'returns the instance of the class' do
      expect(instance).to eq(client)
    end

    it 'sets the app id' do
      expect(instance.instance_variable_get(:@app_id)).to eq('AppId')
    end

    it 'sets the api token' do
      expect(instance.instance_variable_get(:@api_token)).to eq('SecretToken')
    end

    it 'sets the app environment' do
      expect(instance.instance_variable_get(:@app_env)).to eq('AppEnv')
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
          eq('http://192.168.1.1:42/api/v_newton/my_resource?myParam=1')
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
          eq('http://localhost:4001/api/v_newton/my_resource?')
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
    let(:expected_url) { 'http://localhost:4001/api/v_newton/tasks?' }
    let(:expected_hash) do
      {
        'intent_id' => uuid,
        'programming_language' => 'Ruby',
        'name' => 'FakeTask3',
        'maxProcessingTime' => nil,
        'data' => {
          'o' => '@zenaton#0',
          's' => [{ 'a' => { :@arg1 => 1, :@arg2 => 2 } }]
        }.to_json
      }
    end

    before { start_task }

    it 'sends the serialized task to the worker' do
      expect(http).to have_received(:post)
        .with(expected_url, expected_hash)
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

    context 'with an integer custom id' do
      before { workflow.define_singleton_method(:id) { 123 } }

      it 'sends the custom id as a string' do
        start_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('custom_id' => '123'))
      end
    end

    context 'with an string custom id' do
      before { workflow.define_singleton_method(:id) { 'MyWorkflowId' } }

      it 'sends the custom id' do
        start_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('custom_id' => 'MyWorkflowId'))
      end
    end

    context 'with an invalid custom id type' do
      before { workflow.define_singleton_method(:id) { {} } }

      it 'raises an error' do
        expect { start_workflow }.to \
          raise_error Zenaton::InvalidArgumentError
      end
    end

    context 'with a custom id too long' do
      before { workflow.define_singleton_method(:id) { 'a' * 300 } }

      it 'raises an error' do
        expect { start_workflow }.to \
          raise_error Zenaton::InvalidArgumentError
      end
    end

    context 'without a custom id' do
      it 'sends a post request to the http client' do
        start_workflow
        expect(http).to have_received(:post).with(expected_url, expected_hash)
      end
    end

    context 'with a version workflow' do
      it 'sends the version class name as the canonical name' do
        start_version_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('canonical_name' => 'FakeVersion'))
      end

      it 'sends the workflow name as the name' do
        start_version_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('name' => 'FakeWorkflow2'))
      end
    end
  end

  # rubocop:disable Metrics/LineLength
  describe '#start_scheduled_workflow' do
    let(:start_scheduled_workflow) { client.start_scheduled_workflow(workflow, cron) }
    let(:start_scheduled_version_workflow) { client.start_scheduled_workflow(version, cron) }
    let(:expected_url) { 'https://gateway.zenaton.com/api' }
    let(:expected_query) { Zenaton::Services::GraphQL::CREATE_WORKFLOW_SCHEDULE }
    let(:expected_headers) { { 'app-id' => nil, 'api-token' => nil } }
    let(:expected_variables) do
      {
        'createWorkflowScheduleInput' => {
          'intentId' => uuid,
          'environmentName' => nil,
          'cron' => cron,
          'customId' => nil,
          'workflowName' => 'FakeWorkflow1',
          'canonicalName' => 'FakeWorkflow1',
          'programmingLanguage' => 'RUBY',
          'properties' => {
            'o' => '@zenaton#0',
            's' => [{ 'a' => { :@first => 1, :@second => 2 } }]
          }.to_json
        }
      }
    end

    let(:expected_variables_version_workflow) do
      {
        'createWorkflowScheduleInput' => {
          'intentId' => uuid,
          'environmentName' => nil,
          'cron' => cron,
          'customId' => nil,
          'workflowName' => 'FakeWorkflow2',
          'canonicalName' => 'FakeVersion',
          'programmingLanguage' => 'RUBY',
          'properties' => {
            'o' => '@zenaton#0',
            's' => [{ 'a' => { :@args => '@zenaton#1' } }, { 'a' => [1, 2] }]
          }.to_json
        }
      }
    end

    context 'with a valid workflow' do
      it 'calls the graphQL request' do
        e = [expected_url, expected_query, expected_variables, expected_headers]
        start_scheduled_workflow
        expect(graphql).to have_received(:request).with(*e)
      end
    end

    context 'with a valid version workflow' do
      it 'calls the graphQL request' do
        e = [expected_url, expected_query, expected_variables_version_workflow, expected_headers]
        start_scheduled_version_workflow
        expect(graphql).to have_received(:request).with(*e)
      end
    end
  end
  # rubocop:enable Metrics/LineLength

  describe '#start_scheduled_task' do
    let(:start_scheduled_task) { client.start_scheduled_task(task, cron) }
    let(:expected_url) { 'https://gateway.zenaton.com/api' }
    let(:expected_query) { Zenaton::Services::GraphQL::CREATE_TASK_SCHEDULE }
    let(:expected_headers) { { 'app-id' => nil, 'api-token' => nil } }
    let(:expected_variables) do
      {
        'createTaskScheduleInput' => {
          'intentId' => uuid,
          'environmentName' => nil,
          'cron' => cron,
          'taskName' => 'FakeTask3',
          'programmingLanguage' => 'RUBY',
          'properties' => {
            'o' => '@zenaton#0',
            's' => [{ 'a' => { :@arg1 => 1, :@arg2 => 2 } }]
          }.to_json
        }
      }
    end

    context 'with a valid workflow' do
      it 'calls the graphQL request' do
        e = [expected_url, expected_query, expected_variables, expected_headers]
        start_scheduled_task
        expect(graphql).to have_received(:request).with(*e)
      end
    end
  end

  describe '#kill_workflow' do
    let(:expected_url) do
      'http://localhost:4001/api/v_newton/instances?custom_id=MyCustomId'
    end
    let(:expected_options) do
      {
        'intent_id' => uuid,
        'programming_language' => 'Ruby',
        'name' => 'MyWorkflow',
        'mode' => 'kill'
      }
    end

    before { client.kill_workflow('MyWorkflow', 'MyCustomId') }

    it 'makes a put request' do
      expect(http).to have_received(:put).with(expected_url, expected_options)
    end
  end

  describe '#pause_workflow' do
    let(:expected_url) do
      'http://localhost:4001/api/v_newton/instances?custom_id=MyCustomId'
    end
    let(:expected_options) do
      {
        'intent_id' => uuid,
        'programming_language' => 'Ruby',
        'name' => 'MyWorkflow',
        'mode' => 'pause'
      }
    end

    before { client.pause_workflow('MyWorkflow', 'MyCustomId') }

    it 'makes a put request' do
      expect(http).to have_received(:put).with(expected_url, expected_options)
    end
  end

  describe '#resume_workflow' do
    let(:expected_url) do
      'http://localhost:4001/api/v_newton/instances?custom_id=MyCustomId'
    end
    let(:expected_options) do
      {
        'intent_id' => uuid,
        'programming_language' => 'Ruby',
        'name' => 'MyWorkflow',
        'mode' => 'run'
      }
    end

    before { client.resume_workflow('MyWorkflow', 'MyCustomId') }

    it 'makes a put request' do
      expect(http).to have_received(:put).with(expected_url, expected_options)
    end
  end

  describe '#find_workflow' do
    let(:expected_url) do
      'https://api.zenaton.com/v1/instances?custom_id=MyCustomId&name=FakeWorkflow1&programming_language=Ruby&api_token=ApiToken'
    end
    let(:result) do
      client.find_workflow('FakeWorkflow1', 'MyCustomId')
    end

    context 'when there is a matching workflow' do
      before do
        described_class.init(nil, 'ApiToken', nil)
        allow(http).to receive(:get)
          .with(expected_url)
          .and_return(sample_response)
      end

      let(:sample_response) do
        {
          'data' => {
            'status' => 'ok',
            'properties' => '{"a":{"@id":2,"@max":10},"s":[]}',
            'name' => 'FakeWorkflow1',
            'mode' => 'paused',
            'custom_id' => 'MyCustomId',
            'canonical_name' => 'FakeWorkflow1'
          }
        }
      end

      it 'returns the requested instance' do
        expect(result).to be_a FakeWorkflow1
      end

      it 'sets the instance variable of the workflow' do
        expect(result.instance_variable_get(:@id)).to eq(2)
      end
    end

    context 'when there is no matching workflow' do
      before do
        described_class.init(nil, 'ApiToken', nil)
        allow(http).to receive(:get)
          .with(expected_url)
          .and_raise(Zenaton::InternalError,
                     '404: No workflow instance found with the id : MyCustomId')
      end

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'when another exception is raised' do
      before do
        described_class.init(nil, 'ApiToken', nil)
        allow(http).to receive(:get)
          .with(expected_url)
          .and_raise(Zenaton::InternalError, 'Oopsies')
      end

      it 'raises the exception' do
        expect { result }.to raise_error Zenaton::InternalError, 'Oopsies'
      end
    end
  end

  describe '#send_event' do
    let(:expected_url) do
      'http://localhost:4001/api/v_newton/events?'
    end
    let(:expected_options) do
      {
        'intent_id' => uuid,
        'programming_language' => 'Ruby',
        'name' => 'MyWorkflow',
        'custom_id' => 'MyCustomId',
        'event_name' => 'FakeEvent',
        'event_input' => {
          'o' => '@zenaton#0',
          's' => [{ 'a' => {} }]
        }.to_json,
        'event_data' => {
          'o' => '@zenaton#0',
          's' => [{ 'n' => 'FakeEvent', 'p' => {} }]
        }.to_json
      }
    end

    before { client.send_event('MyWorkflow', 'MyCustomId', event) }

    it 'makes a post request' do
      expect(http).to have_received(:post).with(expected_url, expected_options)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def setup_client
    Singleton.__init__(described_class)
    allow(Zenaton::Services::Http).to receive(:new).and_return(http)
    allow(Zenaton::Services::GraphQL).to receive(:new).and_return(graphql)
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
  end
  # rubocop:enable Metrics/AbcSize
end
