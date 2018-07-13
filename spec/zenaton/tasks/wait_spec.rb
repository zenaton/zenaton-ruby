# frozen_string_literal: true

require 'zenaton/tasks/wait'
require 'fixtures/event'

RSpec.describe Zenaton::Tasks::Wait do
  let(:wait) { described_class.new(event) }
  let(:event) { FakeEvent.new }

  describe 'initialization' do
    context 'with an event' do
      it 'stores the given event as an instance variable' do
        expect(wait.instance_variable_get(:@event)).to eq(event)
      end
    end

    context 'with a string' do
      let(:event) { 'MyEventName' }

      it 'stores the given event as an instance variable' do
        expect(wait.instance_variable_get(:@event)).to eq(event)
      end
    end

    context 'with no arguments' do
      let(:wait) { described_class.new }

      it 'raises an error' do
        expect { wait }.to raise_error Zenaton::ExternalError
      end
    end

    context 'with invalid arguments' do
      let(:event) { ['invalid event type'] }

      it 'raises an error' do
        expect { wait }.to raise_error Zenaton::ExternalError
      end
    end
  end
end
