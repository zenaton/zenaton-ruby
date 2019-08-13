# frozen_string_literal: true

require 'zenaton/refinements/symbol'

RSpec.describe Symbol do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { :foobar.zenaton_properties }

    it { is_expected.to eq(
      's' => 'foobar'
    ) }
  end
end
