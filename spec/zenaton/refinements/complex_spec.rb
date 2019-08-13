# frozen_string_literal: true

require 'zenaton/refinements/complex'

RSpec.describe Complex do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { (1 + 2i).zenaton_properties }

    it { is_expected.to eq(
      'r' => 1,
      'i' => 2
    ) }
  end
end
