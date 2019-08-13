# frozen_string_literal: true

require 'zenaton/refinements/date_time'

RSpec.describe DateTime do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { described_class.parse('2018-08-01T08:21:31+02:00').to_zenaton }

    let(:expected_hash) do
      {
        'y' => 2018,
        'm' => 8,
        'd' => 1,
        'H' => 8,
        'M' => 21,
        'S' => 31,
        'of' => '1/12',
        'sg' => 2299161.0
      }
    end

    it { is_expected.to eq(expected_hash) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) do
      {
        'y' => 2018,
        'm' => 8,
        'd' => 1,
        'H' => 8,
        'M' => 21,
        'S' => 31,
        'of' => '1/12',
        'sg' => 2299161.0
      }
    end
    let(:expected) { described_class.parse('2018-08-01T08:21:31+02:00') }

    it { is_expected.to eq(expected) }
  end
end
