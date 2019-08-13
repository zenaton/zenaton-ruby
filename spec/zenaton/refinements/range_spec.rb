# frozen_string_literal: true

require 'zenaton/refinements/range'

RSpec.describe Range do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    context "with upper limit included" do
      subject { (1..5).zenaton_properties }

      it { is_expected.to eq(
        'a' => [1, 5, false]
      ) }
    end

    context "with upper limit excluded" do
      subject { (1...5).zenaton_properties }

      it { is_expected.to eq(
        'a' => [1, 5, true]
      ) }
    end
  end
end
