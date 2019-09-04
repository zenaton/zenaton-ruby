# frozen_string_literal: true

require 'zenaton/services/graph_ql/resume_workflow_mutation'
require 'fixtures/version'

RSpec.describe Zenaton::Services::GraphQL::ResumeWorkflowMutation do
  subject(:mutation) { described_class.new(name, custom_id, app_env) }

  let(:name) { 'MySuperWorkflow' }
  let(:custom_id) { '123' }
  let(:app_env) { 'dev' }

  describe 'variables' do
    subject { mutation.variables }

    let(:expected_variables) do
      {
        'input' => {
          'customId' => '123',
          'environmentName' => 'dev',
          'intentId' => String,
          'programmingLanguage' => 'RUBY',
          'name' => 'MySuperWorkflow'
        }
      }
    end

    it { is_expected.to match(expected_variables) }
  end
end
