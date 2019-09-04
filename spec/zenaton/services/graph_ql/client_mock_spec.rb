# frozen_string_literal: true

require './spec/support/stub_http'
require 'zenaton/services/graph_ql/client'
require 'zenaton/services/http'
require 'fixtures/workflows'

RSpec.describe Zenaton::Services::GraphQL::Client do
  subject(:client) { described_class.new(http: http) }

  let(:http) { Zenaton::Services::Http.new }
  let(:graphql_url) { 'http://localhost:2000/api' }
  let(:app_id) { 'QUVSLHMAYN' }
  let(:api_token) do
    'Zp1Wbzoz8L8gXEQ2GHTrnxg6GJ2EMEI16UB2Qy4PgVOjGCBItzbmvGUe6alO'
  end
  let(:app_env) { 'dev' }
  let(:credentials) do
    {
      'app_id' => app_id,
      'api_token' => api_token,
      'app_env' => app_env
    }
  end
  let(:workflow) { FakeWorkflow2.new('first', 'second') }
  let(:cron) { '* * * * *' }

  before do
    allow(SecureRandom).to \
      receive(:uuid)
      .and_return('c7337073-f67c-4517-913c-d0d106f69fa6')
  end

  describe 'Actual request' do
    subject(:request) { client.schedule_workflow(workflow, cron, credentials) }

    around do |example|
      ENV['ZENATON_GATEWAY_URL'] = graphql_url
      example.run
      ENV.delete('ZENATON_GATEWAY_URL')
    end

    context 'when the request is successful' do
      let(:expected_response) do
        {
          'createWorkflowSchedule' => {
            'schedule' => {
              'id' => 'c7337073-f67c-4517-913c-d0d106f69fa6'
            }
          }
        }
      end

      around do |example|
        VCR.use_cassette('graphql_ok') { example.run }
      end

      it { is_expected.to eq(expected_response) }
    end

    context 'when the request is invalid' do
      let(:cron) { nil }

      around do |example|
        VCR.use_cassette('graphql_error') { example.run }
      end

      it 'raises an external error' do
        expect { request }.to raise_error Zenaton::ExternalError
      end
    end

    context 'when there is a network error' do
      before do
        allow(Net::HTTP).to \
          receive(:start)
          .and_raise(Timeout::Error)
      end

      it 'raises a connection error' do
        expect { request }.to raise_error Zenaton::ConnectionError
      end
    end
  end
end
