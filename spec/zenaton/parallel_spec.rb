# frozen_string_literal: true

require 'zenaton/parallel'
require 'fixtures/tasks'

RSpec.describe Zenaton::Parallel do
  let(:parallel) { described_class.new(task1, task2) }
  let(:task1) { FakeTask1.new }
  let(:task2) { FakeTask2.new }
  let(:engine) do
    instance_double(
      Zenaton::Engine,
      dispatch: nil,
      execute: nil
    )
  end

  before { setup_engine }

  it 'stores given jobs a an instance variable' do
    expect(parallel.instance_variable_get(:@items)).to eq([task1, task2])
  end

  it 'executes through the engine' do
    parallel.execute
    expect(engine).to have_received(:execute).with([task1, task2])
  end

  it 'dispatches through the engine' do
    parallel.dispatch
    expect(engine).to have_received(:dispatch).with([task1, task2])
  end

  def setup_engine
    allow(Zenaton::Engine).to receive(:instance).and_return(engine)
  end
end
