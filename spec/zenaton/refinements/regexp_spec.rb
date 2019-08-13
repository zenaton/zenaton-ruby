# frozen_string_literal: true

require 'zenaton/refinements/regexp'

RSpec.describe Regexp do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    context "with options" do
      subject { /[a-z]/i.zenaton_properties }

      it { is_expected.to eq(
        'o' => 1,
        's' => '[a-z]'
      ) }
    end

    context "without options" do
      subject { (/(.)+/).zenaton_properties }

      it { is_expected.to eq(
        'o' => 0,
        's' => '(.)+'
      ) }
    end
  end
end
