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
    context 'with a canonical worflow' do
      let(:start_workflow) { client.start_workflow(workflow) }

      it 'delegates to the graphql client' do
        start_workflow
        expect(graphql).to \
          have_received(:start_workflow)
          .with(workflow, credentials)
      end
    end

    context 'with a version workflow' do
      let(:start_version_workflow) { client.start_workflow(version) }

      it 'delegates to the graphql client' do
        start_version_workflow
        expect(graphql).to \
          have_received(:start_workflow)
          .with(version, credentials)
      end
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
    described_class.init(*credentials.values)
  end
  # rubocop:enable Metrics/AbcSize
end
