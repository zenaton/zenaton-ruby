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

    it { is_expected.to match(expected_variables) }
  end
end
