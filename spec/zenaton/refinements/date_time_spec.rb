# frozen_string_literal: true

require 'zenaton/refinements/date_time'

RSpec.describe DateTime do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { described_class.parse('2018-08-01T08:21:31+02:00').zenaton_props }

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
end
