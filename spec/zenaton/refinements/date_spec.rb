# frozen_string_literal: true

require 'zenaton/refinements/date'

RSpec.describe Date do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { described_class.new(2018, 8, 1).to_zenaton }

    let(:expected) do
      {
        'y' => 2018,
        'm' => 8,
        'd' => 1,
        'sg' => 2299161.0
      }
    end

    it { is_expected.to eq(expected) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) do
      {
        'y' => 2018,
        'm' => 8,
        'd' => 1,
        'sg' => 2299161.0
      }
    end

    it { is_expected.to eq(described_class.new(2018, 8, 1)) }
  end
end
