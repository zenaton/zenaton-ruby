# frozen_string_literal: true

require 'zenaton/interfaces/workflow'

RSpec.describe Zenaton::Interfaces::Workflow do
  let(:flow) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { flow.handle }.to raise_error Zenaton::NotImplemented
    end
  end

  describe 'context' do
    subject(:flow_context) { flow.context }

    context 'when not yet set' do
      it { is_expected.to be_a(Zenaton::Contexts::Workflow) }

      it 'has no id' do
        expect(flow_context.id).to be_nil
      end

      it 'can be set' do
        expect { flow.add_context(id: 'some-uuid') }.not_to raise_error
      end

      it 'can update the context id' do
        flow.add_context(id: 'some-uuid')
        expect(flow_context.id).to eq('some-uuid')
      end
    end

    context 'when already set' do
      def safely_set(flow, **attrs)
        flow.add_context(attrs)
      rescue ArgumentError => e
        e
      end

      before { flow.add_context(id: 'some-uuid') }

      it { is_expected.to be_a(Zenaton::Contexts::Workflow) }

      it 'has an id' do
        expect(flow_context.id).to eq('some-uuid')
      end

      it 'cannot be set' do
        expect { flow.add_context(id: 'some-uuid') }.to \
          raise_error ArgumentError
      end

      it 'cannot update the context id' do
        expect { safely_set(flow, id: 'other-uuid') }.not_to \
          change(flow, :context)
      end
    end
  end
end
