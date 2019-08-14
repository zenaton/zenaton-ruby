# frozen_string_literal: true

require 'zenaton/contexts/task'

RSpec.describe Zenaton::Contexts::Task do
  describe 'initialization' do
    subject(:task_context) { described_class.new(**args) }

    context 'when nothing is passed' do
      let(:args) { {} }

      it 'has no id' do
        expect(task_context.id).to be_nil
      end

      it 'has no attempt index' do
        expect(task_context.attempt_index).to be_nil
      end
    end

    context 'when id and attempt index are provided' do
      let(:args) { { id: 'some-uuid', attempt_index: 10 } }

      it 'sets the id' do
        expect(task_context.id).to eq('some-uuid')
      end

      it 'sets the attempt index' do
        expect(task_context.attempt_index).to eq(10)
      end
    end

    context 'when other arguments are passed' do
      let(:args) { { some: 'invalid', extra: 'attributes' } }

      it 'has no id' do
        expect(task_context.id).to be_nil
      end

      it 'has no attempt index' do
        expect(task_context.attempt_index).to be_nil
      end

      it 'does not set getter methods' do
        expect { task_context.some }.to raise_error NoMethodError
      end

      it 'does not set the extra attributes' do
        expect(task_context.instance_variables).to eq(%i[@id @attempt_index])
      end
    end
  end
end
