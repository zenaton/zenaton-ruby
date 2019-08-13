# frozen_string_literal: true

require 'zenaton/refinements/exception'

RSpec.describe Exception do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { StandardError.new('oops').zenaton_properties }

    it { is_expected.to eq(
      'm' => 'oops',
      'b' => nil
    ) }
  end
end
