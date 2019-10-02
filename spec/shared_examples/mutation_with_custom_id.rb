# frozen_string_literal: true

require 'fixtures/version'

RSpec.shared_examples 'Mutation with CustomId' do
  describe 'custom IDs' do
    context 'when there is no custom ID' do
      let(:workflow) { FakeWorkflow2.new(1, 2) }
      let(:custom_id) { mutation.variables['input']['customId'] }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end

      it 'sets custom id in the variables' do
        expect(custom_id).to be_nil
      end
    end

    context 'when the custom is nil' do
      let(:workflow) { FakeWorkflowWithID.new(nil) }
      let(:custom_id) { mutation.variables['input']['customId'] }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end

      it 'sets custom id in the variables' do
        expect(custom_id).to be_nil
      end
    end

    context 'when the custom is a string shorter than 256 chars' do
      let(:workflow) { FakeWorkflowWithID.new('my-custom-id') }
      let(:custom_id) { mutation.variables['input']['customId'] }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end

      it 'sets the custom id in the variables' do
        expect(custom_id).to eq('my-custom-id')
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
      let(:custom_id) { mutation.variables['input']['customId'] }

      it 'does not raise any exception' do
        expect { mutation }.not_to raise_exception
      end

      it 'casts the custom id into a string' do
        expect(custom_id).to eq('123')
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
end
