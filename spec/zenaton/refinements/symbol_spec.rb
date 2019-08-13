# frozen_string_literal: true

require 'zenaton/refinements/symbol'

RSpec.describe Symbol do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { :foobar.zenaton_props }

    it { is_expected.to eq('s' => 'foobar') }
  end
end
