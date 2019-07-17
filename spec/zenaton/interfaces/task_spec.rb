# frozen_string_literal: true

require 'zenaton/interfaces/task'
require 'shared_examples/repeatable'

RSpec.describe Zenaton::Interfaces::Task do
  let(:task) { described_class.new }

  it_behaves_like 'Repeatable'

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { task.handle }.to raise_error Zenaton::NotImplemented
    end
  end
end
