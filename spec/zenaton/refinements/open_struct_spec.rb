# frozen_string_literal: true

require 'zenaton/refinements/open_struct'

RSpec.describe OpenStruct do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { OpenStruct.new(a: 1).zenaton_properties }

    it { is_expected.to eq(
      't' => { a: 1 }
    ) }
  end
end
