# frozen_string_literal: true

require 'zenaton/services/graph_ql/create_workflow_schedule_mutation'
require 'fixtures/version'
require 'shared_examples/mutation_with_custom_id'

RSpec.describe Zenaton::Services::GraphQL::CreateWorkflowScheduleMutation do
  subject(:mutation) { described_class.new(workflow, cron, app_env) }

  let(:app_env) { 'dev' }
  let(:cron) { '* * * * *' }

  it_behaves_like 'Mutation with CustomId'

  describe 'variables' do
    subject { mutation.variables }

    context 'with a simple workflow' do
      let(:workflow) { FakeWorkflow2.new(1, 2) }
      let(:expected_variables) do
        {
          'input' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
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

      it { is_expected.to match(expected_variables) }
    end

    context 'with a custom id' do
      let(:workflow) { FakeWorkflowWithID.new('my-custom-id') }
      let(:expected_variables) do
        {
          'input' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'customId' => 'my-custom-id',
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

    context 'with an integer custom id' do
      let(:workflow) { FakeWorkflowWithID.new(123) }
      let(:expected_variables) do
        {
          'input' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'customId' => '123',
            'workflowName' => 'FakeWorkflowWithID',
            'canonicalName' => 'FakeWorkflowWithID',
            'programmingLanguage' => 'RUBY',
            'properties' => {
              o: '@zenaton#0',
              s: [{ a: { '@custom_id': 123 } }]
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
          'input' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'customId' => nil,
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
