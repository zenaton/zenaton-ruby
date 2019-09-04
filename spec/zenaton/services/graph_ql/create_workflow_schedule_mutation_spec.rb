# frozen_string_literal: true

require 'zenaton/services/graph_ql/create_workflow_schedule_mutation'
require 'fixtures/version'

RSpec.describe Zenaton::Services::GraphQL::CreateWorkflowScheduleMutation do
  subject(:mutation) { described_class.new(workflow, cron, app_env) }

  let(:app_env) { 'dev' }
  let(:cron) { '* * * * *' }

  describe 'variables' do
    subject { mutation.variables }

    context 'with a simple workflow' do
      let(:workflow) { FakeWorkflow2.new(1, 2) }
      let(:expected_variables) do
        {
          'createWorkflowScheduleInput' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
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

      it { is_expected.to match(expected_variables) }
    end

    context 'with a custom id' do
      let(:workflow) { FakeWorkflowWithID.new('my-custom-id') }
      let(:expected_variables) do
        {
          'createWorkflowScheduleInput' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'workflowName' => 'FakeWorkflowWithID',
            'canonicalName' => 'FakeWorkflowWithID',
            'programmingLanguage' => 'RUBY',
            'properties' => {
              o: '@zenaton#0',
              s: [{ a: { '@custom_id': 'my-custom-id' } }]
            }.to_json
          }
        }
      end

      it { is_expected.to match(expected_variables) }
    end

    context 'with a versionned workflow' do
      let(:workflow) { FakeVersion.new(1, 2) }
      let(:expected_variables) do
        {
          'createWorkflowScheduleInput' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'workflowName' => 'FakeWorkflow2',
            'canonicalName' => 'FakeVersion',
            'programmingLanguage' => 'RUBY',
            'properties' => {
              o: '@zenaton#0',
              s: [
                { a: { '@args': '@zenaton#1' } },
                { a: [1, 2] }
              ]
            }.to_json
          }
        }
      end

      it { is_expected.to match(expected_variables) }
    end
  end
end
