# frozen_string_literal: true

require 'zenaton/client'

RSpec.describe Zenaton::Client do
  let(:client) { described_class.instance }

  describe 'initialization' do
    it 'there is only a single instance of the class' do
      client2 = described_class.instance
      expect(client).to eq(client2)
    end

    it 'cannot be initialized' do
      expect { described_class.new }.to \
        raise_error NoMethodError, /private method `new' called/
    end
  end
end
