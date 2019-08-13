# frozen_string_literal: true

require 'zenaton/refinements/datetime'

RSpec.describe DateTime do
  using Zenaton::Refinements
 
  describe "#zenaton_properties" do
    subject { DateTime.parse('2018-08-01T08:21:31+02:00').zenaton_properties }

    it { is_expected.to eq(
      'y' => 2018,
      'm' => 8,
      'd' => 1,
      'H' => 8,
      'M' => 21,
      'S' => 31,
      'of' => '1/12',
      'sg' => 2299161.0
    ) }
  end
end
