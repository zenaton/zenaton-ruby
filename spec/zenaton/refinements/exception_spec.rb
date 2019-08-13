# frozen_string_literal: true

require 'zenaton/refinements/exception'

RSpec.describe Exception do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { StandardError.new('oops').to_zenaton }

    it { is_expected.to eq('m' => 'oops', 'b' => nil) }
  end

  describe '.from_zenaton' do
    subject { StandardError.from_zenaton(props) }

    let(:props) { { 'm' => 'oops', 'b' => nil } }

    it { is_expected.to eq(StandardError.new('oops')) }
  end
end
