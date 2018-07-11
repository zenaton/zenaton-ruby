# frozen_string_literal: true

require 'zenaton/task'

RSpec.describe Zenaton::Task do
  let(:task) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { task.handle }.to raise_error Zenaton::NotImplemented
    end
  end
end
