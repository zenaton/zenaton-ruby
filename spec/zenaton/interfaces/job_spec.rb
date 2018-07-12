# frozen_string_literal: true

require 'zenaton/interfaces/job'

RSpec.describe Zenaton::Interfaces::Job do
  let(:job) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { job.handle }.to raise_error Zenaton::NotImplemented
    end
  end
end
