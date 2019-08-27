# frozen_string_literal: true

require 'zenaton/contexts/workflow'

RSpec.describe Zenaton::Contexts::Workflow do
  describe 'initialization' do
    subject(:flow_context) { described_class.new(**args) }

    context 'when nothing is passed' do
      let(:args) { {} }

      it 'has no id' do
        expect(flow_context.id).to be_nil
      end
    end

    context 'when id is provided' do
      let(:args) { { id: 'some-uuid' } }

      it 'sets the id' do
        expect(flow_context.id).to eq('some-uuid')
      end
    end

    context 'when other arguments are passed' do
      let(:args) { { some: 'invalid', extra: 'attributes' } }

      it 'has no id' do
        expect(flow_context.id).to be_nil
      end

      it 'does not set getter methods' do
        expect { flow_context.some }.to raise_error NoMethodError
      end

      it 'does not set the extra attributes' do
        expect(flow_context.instance_variables).to eq([:@id])
      end
    end
  end
end
