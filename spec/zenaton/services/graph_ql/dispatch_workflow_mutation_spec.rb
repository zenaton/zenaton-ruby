# frozen_string_literal: true

require 'zenaton/services/graph_ql/dispatch_workflow_mutation'
require 'fixtures/version'

RSpec.describe Zenaton::Services::GraphQL::DispatchWorkflowMutation do
  subject(:mutation) { described_class.new(workflow, app_env) }

  let(:app_env) { 'dev' }

  describe 'custom IDs' do
    context 'when there is no custom ID' do
      let(:workflow) { FakeWorkflow2.new(1, 2) }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end
    end

    context 'when the custom is nil' do
      let(:workflow) { FakeWorkflowWithID.new(nil) }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end
    end

    context 'when the custom is a string shorter than 256 chars' do
      let(:workflow) { FakeWorkflowWithID.new('my-custom-id') }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end
    end

    context 'when the custom is a string longer than 256 chars' do
      let(:workflow) { FakeWorkflowWithID.new('*' * 257) }

      it 'raises an exception' do
        expect { mutation }.to raise_exception Zenaton::InvalidArgumentError
      end
    end

    context 'when the custom is an integer shorter than 256 digits' do
      let(:workflow) { FakeWorkflowWithID.new(123) }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end
    end

    context 'when the custom is an integer longer than 256 digits' do
      let(:workflow) { FakeWorkflowWithID.new(('1' * 257).to_i) }

      it 'raises an exception' do
        expect { mutation }.to raise_exception Zenaton::InvalidArgumentError
      end
    end

    context 'when the custom id is from any another type' do
      let(:workflow) { FakeWorkflowWithID.new(:symbol) }

      it 'raises an exception' do
        expect { mutation }.to raise_exception Zenaton::InvalidArgumentError
      end
    end
  end

  describe 'variables' do
    subject { mutation.variables }

    context 'with a simple workflow' do
      let(:workflow) { FakeWorkflow2.new(1, 2) }
      let(:expected_variables) do
        {
          'input' => {
            'customId' => nil,
            'environmentName' => 'dev',
            'intentId' => String,
            'programmingLanguage' => 'RUBY',
            'name' => 'FakeWorkflow2',
            'canonicalName' => 'FakeWorkflow2',
            'data' => {
              o: '@zenaton#0',
              s: [{ a: {} }]
            }.to_json
          }
        }
      end

      it { is_expected.to match(expected_variables) }
    end

    context 'with a string custom id' do
      let(:workflow) { FakeWorkflowWithID.new('my-custom-id') }
      let(:expected_variables) do
        {
          'input' => {
            'customId' => 'my-custom-id',
            'environmentName' => 'dev',
            'intentId' => String,
            'programmingLanguage' => 'RUBY',
            'name' => 'FakeWorkflowWithID',
            'canonicalName' => 'FakeWorkflowWithID',
            'data' => {
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
            'customId' => '123',
            'environmentName' => 'dev',
            'intentId' => String,
            'programmingLanguage' => 'RUBY',
            'name' => 'FakeWorkflowWithID',
            'canonicalName' => 'FakeWorkflowWithID',
            'data' => {
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
            'customId' => nil,
            'environmentName' => 'dev',
            'intentId' => String,
            'programmingLanguage' => 'RUBY',
            'name' => 'FakeWorkflow2',
            'canonicalName' => 'FakeVersion',
            'data' => {
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
