# frozen_string_literal: true

require 'zenaton/refinements/time'

RSpec.describe Time do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { Time.at(15).zenaton_properties }

    it { is_expected.to eq('s' => 15, 'n' => 0) }
  end
end
