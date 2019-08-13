# frozen_string_literal: true

require 'zenaton/refinements/struct'

RSpec.describe  do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { Struct::Customer.new(name: 'alice').zenaton_properties }

    before { Struct.new('Customer', :name) }

    it { is_expected.to eq(
      'v' => [{name: 'alice'}]
    ) }
  end
end
