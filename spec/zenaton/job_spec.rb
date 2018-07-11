# frozen_string_literal: true

require 'zenaton/job'

RSpec.describe Zenaton::Job do
  let(:job) { described_class.new }

  describe '#handle' do
    it 'raises a not implemented error' do
      expect { job.handle }.to raise_error Zenaton::NotImplemented
    end
  end
end
