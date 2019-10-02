# frozen_string_literal: true

require 'zenaton/services/graph_ql/client'
require 'zenaton/services/http'
require 'fixtures/tasks'
require 'fixtures/workflows'

RSpec.describe Zenaton::Services::GraphQL::Client do
  subject(:client) { described_class.new(http: http) }

  let(:http) { instance_double(Zenaton::Services::Http, post: response) }
  let(:credentials) do
    {
      'app_id' => 'my-app-id',
      'api_token' => '123456',
      'app_env' => 'dev'
    }
  end
  let(:task) { FakeTask1.new }
  let(:workflow) { FakeWorkflow2.new('first', 'second') }
  let(:cron) { '* * * * *' }
  let(:response) { { 'data': '' } }

  describe 'Request url' do
    before { client.schedule_workflow(workflow, cron, credentials) }

    context 'without a custom GraphQL endpoint' do
      let(:graphql_url) { 'https://gateway.zenaton.com/api' }

      it 'posts to the default url' do
        expect(http).to \
          have_received(:post)
          .with(graphql_url, any_args)
      end
    end

    context 'with a custom GraphQL endpoint' do
      let(:graphql_url) { 'https://custom.graphql/api' }

      around do |example|
        ENV['ZENATON_GATEWAY_URL'] = graphql_url
        example.run
        ENV.delete('ZENATON_GATEWAY_URL')
      end

      it 'posts to the custom url' do
        expect(http).to \
          have_received(:post)
          .with(graphql_url, any_args)
      end
    end
  end

  describe 'Request body' do
    context 'when scheduling a workflow' do
      before { client.schedule_workflow(workflow, cron, credentials) }

      let(:raw_query) do
        <<~GQL
          mutation ($input: CreateWorkflowScheduleInput!) {
            createWorkflowSchedule(input: $input) {
              schedule {
                id
              }
            }
          }
        GQL
      end

      let(:query) { raw_query.gsub(/\s+/, ' ') }

      let(:variables) do
        {
          'input' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => cron,
            'customId' => nil,
            'workflowName' => 'FakeWorkflow2',
            'canonicalName' => 'FakeWorkflow2',
            'programmingLanguage' => 'RUBY',
            'properties' => {
              o: '@zenaton#0',
              s: [{ a: {} }]
            }.to_json
          }
        }
      end

      it 'sends the grapqhl query' do
        expect(http).to \
          have_received(:post)
          .with(anything, hash_including('query' => query), anything)
      end

      it 'sends the grapqhl variables' do
        expect(http).to \
          have_received(:post)
          .with(anything, hash_including('variables' => variables), anything)
      end
    end

    context 'when scheduling a task' do
      before { client.schedule_task(task, cron, credentials) }

      let(:raw_query) do
        <<~GQL
          mutation ($input: CreateTaskScheduleInput!) {
            createTaskSchedule(input: $input) {
              schedule {
                id
              }
            }
          }
        GQL
      end

      let(:query) { raw_query.gsub(/\s+/, ' ') }

      let(:variables) do
        {
          'input' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => cron,
            'taskName' => 'FakeTask1',
            'programmingLanguage' => 'RUBY',
            'properties' => {
              o: '@zenaton#0',
              s: [{ a: {} }]
            }.to_json
          }
        }
      end

      it 'sends the grapqhl query' do
        expect(http).to \
          have_received(:post)
          .with(anything, hash_including('query' => query), anything)
      end

      it 'sends the grapqhl variables' do
        expect(http).to \
          have_received(:post)
          .with(anything, hash_including('variables' => variables), anything)
      end
    end
  end

  describe 'Request headers' do
    before { client.schedule_workflow(workflow, cron, credentials) }

    let(:expected_headers) do
      {
        'app-id' => 'my-app-id',
        'api-token' => '123456'
      }
    end

    it 'sends the credentials in the header' do
      expect(http).to \
        have_received(:post)
        .with(anything, anything, expected_headers)
    end
  end
end
