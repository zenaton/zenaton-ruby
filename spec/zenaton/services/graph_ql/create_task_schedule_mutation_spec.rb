# frozen_string_literal: true

require 'zenaton/services/graph_ql/create_task_schedule_mutation'
require 'fixtures/tasks'

RSpec.describe Zenaton::Services::GraphQL::CreateTaskScheduleMutation do
  subject(:mutation) { described_class.new(task, cron, app_env) }

  let(:app_env) { 'dev' }
  let(:cron) { '* * * * *' }

  describe 'variables' do
    subject { mutation.variables }

    context 'without max processing time' do
      let(:task) { FakeTask1.new }
      let(:expected_variables) do
        {
          'createTaskScheduleInput' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'taskName' => 'FakeTask1',
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

    context 'with max processing time' do
      let(:task) { FakeTaskMPT.new(1000) }
      let(:expected_variables) do
        {
          'createTaskScheduleInput' => {
            'intentId' => String,
            'environmentName' => 'dev',
            'cron' => '* * * * *',
            'taskName' => 'FakeTaskMPT',
            'programmingLanguage' => 'RUBY',
            'properties' => {
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
