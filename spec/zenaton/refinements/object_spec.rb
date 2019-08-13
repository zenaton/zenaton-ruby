# frozen_string_literal: true

require 'zenaton/refinements/object'

RSpec.describe Object do
  using Zenaton::Refinements

  subject(:object) { described_class.new }

  describe '#to_zenaton' do
    context 'without any instance variables' do
      it 'returns an empty hash' do
        expect(object.to_zenaton).to eq({})
      end
    end

    context 'with instance variables' do
      before do
        object.instance_variable_set(:@foo, 'bar')
        object.instance_variable_set(:@foo2, 'bar2')
      end

      it 'returns a hash of the instance variables' do
        expect(object.to_zenaton).to \
          eq(:@foo => 'bar', :@foo2 => 'bar2')
      end
    end
  end
end
