# frozen_string_literal: true

require 'zenaton/refinements/open_struct'

RSpec.describe OpenStruct do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { described_class.new(a: 1).zenaton_props }

    it { is_expected.to eq('t' => { a: 1 }) }
  end
end
