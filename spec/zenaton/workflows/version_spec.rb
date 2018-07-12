# frozen_string_literal: true

require 'zenaton/workflows/version'
require 'shared_examples/zenatonable'
require 'fakes/version'

RSpec.describe Zenaton::Workflows::Version do
  let(:version) { FakeVersion.new(1, 2, 3) }

  it_behaves_like 'Zenatonable'

  describe 'initialization' do
    it 'stores receveived arguments in a instance variable' do
      expect(version.instance_variable_get(:@args)).to eq([1, 2, 3])
    end
  end

  describe '#current' do
    it 'returns the most recent version' do
      expect(version.current).to eq(Workflow2)
    end
  end

  describe '#initial' do
    it 'returns the oldest version' do
      expect(version.initial).to eq(Workflow1)
    end
  end

  describe '#current_implementation' do
    it 'returns an instance of the workflow' do
      expect(version.current_implementation).to be_a Workflow2
    end
  end
end
