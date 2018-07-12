# frozen_string_literal: true

require 'zenaton/interfaces/workflow'

RSpec.describe Zenaton::Interfaces::Workflow do
  let(:flow) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { flow.handle }.to raise_error Zenaton::NotImplemented
    end
  end
end
