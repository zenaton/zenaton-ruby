# frozen_string_literal: true

require 'zenaton/workflow'

RSpec.describe Zenaton::Workflow do
  let(:flow) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { flow.handle }.to raise_error Zenaton::NotImplemented
    end
  end
end
