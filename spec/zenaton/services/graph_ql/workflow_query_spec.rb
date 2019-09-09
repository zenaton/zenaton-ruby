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

  describe 'result from response' do
    subject(:workflow) { query.result(response['data']) }

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
end
