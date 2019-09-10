# frozen_string_literal: true

require 'zenaton/services/graph_ql/workflow_query'
require 'fixtures/version'

RSpec.describe Zenaton::Services::GraphQL::WorkflowQuery do
  subject(:query) { described_class.new(name, custom_id, app_env) }

  let(:name) { 'MySuperWorkflow' }
  let(:custom_id) { '123' }
  let(:app_env) { 'dev' }

  describe 'variables' do
    subject { query.variables }

    let(:expected_variables) do
      {
        'customId' => '123',
        'environmentName' => 'dev',
        'programmingLanguage' => 'RUBY',
        'workflowName' => 'MySuperWorkflow'
      }
    end

    it { is_expected.to eq(expected_variables) }
  end

  describe 'handling response' do
    subject(:result) { query.result(response) }

    context 'with a success' do
      let(:response) do
        {
          'data' => {
            'findWorkflow' => {
              'name' => 'FakeWorkflow2',
              'properties' => '{"o":"@zenaton#0","s":[{"a":{"@a":0,"@b":10}}]}'
            }
          }
        }
      end

      it { is_expected.to be_a(FakeWorkflow2) }
    end

    context 'with a not found error' do
      let(:response) do
        {
          'data' => {
            'findWorkflow' => nil
          },
          'errors' => [{
            'error_id' => 'FcMNnz2RVbdVzogAAANR',
            'locations' => [{
              'column' => 0,
              'line' => 1
            }],
            'message' => "Instance 'EventWorkflow' with id 'foobar' not found",
            'path' => ['findWorkflow'],
            'type' => 'NOT_FOUND'
          }]
        }
      end

      it { is_expected.to be_nil }
    end

    context 'with another error' do
      # rubocop:disable Metrics/LineLength
      let(:response) do
        {
          'errors' => [{
            'locations' => [{
              'column' => 0,
              'line' => 1
            }],
            'message' => 'In argument \'environmentName\': Expected type \'String!\', found null.'
          }, {
            'locations' => [{
              'column' => 0,
              'line' => 1
            }, {
              'column' => 0,
              'line' => 1
            }],
            'message' => 'Variable \'environmentName\' is never used.'
          }]
        }
      end
      # rubocop:enable Metrics/LineLength

      let(:message) do
        <<~ERROR
          - In argument 'environmentName': Expected type 'String!', found null.
          - Variable 'environmentName' is never used.
        ERROR
      end

      it 'raises a Zenaton error' do
        expect { result }.to raise_error Zenaton::ExternalError, message.strip
      end
    end
  end
end
