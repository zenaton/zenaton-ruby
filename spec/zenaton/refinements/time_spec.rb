# frozen_string_literal: true

require 'zenaton/refinements/time'

RSpec.describe Time do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { described_class.at(15).zenaton_props }

    it { is_expected.to eq('s' => 15, 'n' => 0) }
  end
end
