# frozen_string_literal: true

require 'zenaton/tasks/wait'
require 'fixtures/event'
require 'shared_examples/with_duration'
require 'shared_examples/with_timestamp'
require 'shared_examples/zenatonable'

RSpec.describe Zenaton::Tasks::Wait do
  let(:wait) { described_class.new(event_class) }
  let(:event_class) { FakeEvent }

  it_behaves_like 'WithDuration', FakeEvent
  it_behaves_like 'WithTimestamp', FakeEvent
  it_behaves_like 'Zenatonable', FakeEvent

  describe 'initialization' do
    context 'with an event' do
      it 'stores the given event class as an instance variable' do
        expect(wait.instance_variable_get(:@event)).to eq(event_class)
      end
    end

    context 'with a string' do
      let(:event_class) { 'FakeEvent' }

      it 'stores the given event class as an instance variable' do
        expect(wait.instance_variable_get(:@event)).to eq('FakeEvent')
      end
    end

    context 'with no arguments' do
      let(:wait) { described_class.new }

      it 'stores no event' do
        expect(wait.instance_variable_get(:@event)).to be_nil
      end
    end

    context 'with invalid arguments' do
      let(:event_class) { {} }

      it 'raises an error' do
        expect { wait }.to raise_error Zenaton::ExternalError
      end
    end
  end
end
