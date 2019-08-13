# frozen_string_literal: true

require 'zenaton/refinements/date'

RSpec.describe Date do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { described_class.new(2018, 8, 1).zenaton_props }

    it { is_expected.to eq('y' => 2018, 'm' => 8, 'd' => 1, 'sg' => 2299161.0) }
  end
end
