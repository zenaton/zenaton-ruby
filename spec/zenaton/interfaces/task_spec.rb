# frozen_string_literal: true

require 'zenaton/interfaces/task'

RSpec.describe Zenaton::Interfaces::Task do
  subject(:task) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { task.handle }.to raise_error Zenaton::NotImplemented
    end
  end

  describe 'context' do
    subject(:task_context) { task.context }

    context 'when not yet set' do
      it { is_expected.to be_a(Zenaton::Contexts::Task) }

      it 'has no id' do
        expect(task_context.id).to be_nil
      end

      it 'has no attempt index' do
        expect(task_context.retry_index).to be_nil
      end

      it 'can be set' do
        expect { task.add_context(id: 'some-uuid') }.not_to raise_error
      end

      it 'can update the context id' do
        task.add_context(id: 'some-uuid')
        expect(task_context.id).to eq('some-uuid')
      end

      it 'can update the context attempt index' do
        task.add_context(retry_index: 10)
        expect(task_context.retry_index).to eq(10)
      end
    end

    context 'when already set' do
      def safely_set(task, **attrs)
        task.add_context(attrs)
      rescue ArgumentError => e
        e
      end

      before { task.add_context(id: 'some-uuid', retry_index: 10) }

      it { is_expected.to be_a(Zenaton::Contexts::Task) }

      it 'has an id' do
        expect(task_context.id).to eq('some-uuid')
      end

      it 'has an attempt index' do
        expect(task_context.retry_index).to eq(10)
      end

      it 'cannot be set' do
        expect { task.add_context(id: 'some-uuid') }.to \
          raise_error ArgumentError
      end

      it 'cannot update the context id' do
        expect { safely_set(task, id: 'other-uuid') }.not_to \
          change(task, :context)
      end

      it 'cannot update the context attempt index' do
        expect { safely_set(task, retry_index: -1) }.not_to \
          change(task, :context)
      end
    end
  end
end
