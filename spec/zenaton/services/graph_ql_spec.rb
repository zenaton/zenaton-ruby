# frozen_string_literal: true

require './spec/support/stub_http'
require 'zenaton/services/http'
require 'zenaton/services/graphql'

RSpec.describe Zenaton::Services::GraphQL do
  let(:graphql) { described_class.new(http: Zenaton::Services::Http.new) }
  let(:url) { 'http://localhost:2000/api' }
  let(:app_id) { 'JGZREMHIQL' }
  # rubocop:disable Metrics/LineLength
  let(:api_token) { 'MWWkPuaE2HTJWHI3f0VIlIZE4hhLlafs44wIhzRCR0I6tmQ2x2y9EQ0tumsR' }
  # rubocop:enable Metrics/LineLength
  let(:environment) { 'dev' }
  let(:query) { Zenaton::Services::GraphQL::CREATE_WORKFLOW_SCHEDULE }
  let(:headers) do
    {
      'app-id' => app_id,
      'api-token' => api_token
    }
  end

  describe '#request' do
    let(:request) { graphql.request(url, query, variables, headers) }

    context 'when the request is successful' do
      let(:variables) do
        {
          'createWorkflowScheduleInput' => {
            'intentId' => '589a3bf8-638e-4786-a475-d3dd1a976d7b',
            'environmentName' => environment,
            'cron' => '* * * * * *',
            'workflowName' => 'RecurrentWorkflow',
            'canonicalName' => 'RecurrentWorkflow',
            'programmingLanguage' => 'RUBY',
            'properties' => '{}'
          }
        }
      end

      let(:expected_response) do
        {
          'createWorkflowSchedule' => {
            'schedule' => { 'id' => '589a3bf8-638e-4786-a475-d3dd1a976d7b' }
          }
        }
      end

      around do |example|
        VCR.use_cassette('grahpql_ok') { example.run }
      end

      it 'returns the parsed response body' do
        expect(request).to eq(expected_response)
      end
    end

    context 'when the request causes an error' do
      let(:variables) do
        {
          'createWorkflowScheduleInput' => {
            'intentId' => '589a3bf8-638e-4786-a475-d3dd1a976d7b',
            'environmentName' => environment,
            'cron' => nil,
            'workflowName' => 'RecurrentWorkflow',
            'canonicalName' => 'RecurrentWorkflow',
            'programmingLanguage' => 'RUBY',
            'properties' => '{}'
          }
        }
      end

      around do |example|
        VCR.use_cassette('grahpql_validation_errors') { example.run }
      end

      it 'raises an internal error with parsed body as message' do
        expect { request }.to raise_error Zenaton::ExternalError
      end
    end

    context 'when there is a network error' do
      let(:variables) { {} }

      before do
        allow(Net::HTTP).to receive(:start).and_raise(Timeout::Error)
      end

      it 'raises a connection error' do
        expect { request }.to raise_error Zenaton::ConnectionError
      end
    end
  end
end
