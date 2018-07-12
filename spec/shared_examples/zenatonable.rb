# frozen_string_literal: true

RSpec.shared_examples 'Zenatonable' do
  let(:zenatonable) { described_class.new }
  let(:engine) do
    instance_double(
      Zenaton::Engine,
      execute: [1],
      dispatch: [0]
    )
  end

  before do
    allow(Zenaton::Engine).to receive(:instance).and_return(engine)
  end

  it 'dispatches through the engine' do
    expect(zenatonable.dispatch).to eq(0)
  end

  it 'executes through the engine' do
    expect(zenatonable.execute).to eq(1)
  end
end