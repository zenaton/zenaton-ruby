# frozen_string_literal: true

require 'zenaton/services/graph_ql/send_event_mutation'
require 'fixtures/version'
require 'fixtures/event'

RSpec.describe Zenaton::Services::GraphQL::SendEventMutation do
  subject(:mutation) { described_class.new(name, custom_id, event, app_env) }

  let(:name) { 'MySuperWorkflow' }
  let(:custom_id) { '123' }
  let(:event) { FakeEvent.new }
  let(:app_env) { 'dev' }

  describe 'variables' do
    subject { mutation.variables }

    let(:expected_variables) do
      {
        'input' => {
          'customId' => '123',
          'workflowName' => 'MySuperWorkflow',
          'name' => 'FakeEvent',
          'environmentName' => 'dev',
          'intentId' => String,
          'programmingLanguage' => 'RUBY',
          'input' => {
            o: '@zenaton#0',
            s: [{ a: {} }]
          }.to_json,
          'data' => {
            o: '@zenaton#0',
            s: [{ n: 'FakeEvent', p: {} }]
          }.to_json
        }
      }
    end

    it { is_expected.to match(expected_variables) }
  end
end
