# frozen_string_literal: true

require 'zenaton/services/graph_ql/dispatch_task_mutation'
require 'fixtures/tasks'

RSpec.describe Zenaton::Services::GraphQL::DispatchTaskMutation do
  subject(:mutation) { described_class.new(task, app_env) }

  let(:app_env) { 'dev' }

  describe 'variables' do
    subject { mutation.variables }

    context 'without max processing time' do
      let(:task) { FakeTask1.new }
      let(:expected_variables) do
        {
          'input' => {
            'environmentName' => 'dev',
            'intentId' => String,
            'name' => 'FakeTask1',
            'maxProcessingTime' => nil,
            'programmingLanguage' => 'RUBY',
            'data' => {
              o: '@zenaton#0',
              s: [{ a: {} }]
            }.to_json
          }
        }
      end

      it { is_expected.to match(expected_variables) }
    end

    context 'with max processing time' do
      let(:task) { FakeTaskMPT.new(1000) }
      let(:expected_variables) do
        {
          'input' => {
            'environmentName' => 'dev',
            'intentId' => String,
            'name' => 'FakeTaskMPT',
            'maxProcessingTime' => 1000,
            'programmingLanguage' => 'RUBY',
            'data' => {
              o: '@zenaton#0',
              s: [{ a: { '@max_processing_time': 1000 } }]
            }.to_json
          }
        }
      end

      it { is_expected.to match(expected_variables) }
    end
  end
end
