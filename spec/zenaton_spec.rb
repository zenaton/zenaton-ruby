# frozen_string_literal: true

require 'zenaton'

RSpec.describe Zenaton do
  it 'has a version number' do
    expect(Zenaton::VERSION).not_to be nil
  end
end
