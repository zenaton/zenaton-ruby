# frozen_string_literal: true

require 'zenaton/query/builder'
require 'fixtures/workflows'
require 'fixtures/event'

RSpec.describe Zenaton::Query::Builder do
  let(:builder) { described_class.new(klass) }
  let(:klass) { workflow.class }
  let(:workflow) { FakeWorkflow1.new(1, 2) }
  let(:event) { FakeEvent.new }
  let(:client) do
    instance_double(
      Zenaton::Client,
      send_event: nil
    )
  end

  before { setup_client }

  describe 'initialization' do
    context 'when a subclass of workflow is given' do
      it 'stores the given class as an instance variable' do
        expect(builder.instance_variable_get(:@klass)).to eq(FakeWorkflow1)
      end

      it 'stores the client instance as an instance variable' do
        expect(builder.instance_variable_get(:@client)).to eq(client)
      end
    end

    context 'when a non valid class is given' do
      let(:klass) { String }

      it 'raises an error' do
        expect { builder }.to raise_error Zenaton::ExternalError
      end
    end
  end

  describe '#where_id' do
    it 'stores the given id as an instance variable' do
      builder.where_id('MyId')
      expect(builder.instance_variable_get(:@id)).to eq('MyId')
    end
  end

  describe '#find' do
    context 'with an id set' do
      before do
        builder.where_id('MyId')
        allow(client).to receive(:find_workflow)
          .with(FakeWorkflow1, 'MyId')
          .and_return(workflow)
      end

      it 'returns the workflow found by the client' do
        expect(builder.find).to eq(workflow)
      end
    end

    context 'without an id set' do
      before do
        allow(client).to receive(:find_workflow)
          .with(FakeWorkflow1, nil)
          .and_return(workflow)
      end

      it 'returns the workflow found by the client' do
        expect(builder.find).to eq(workflow)
      end
    end
  end

  describe '#send_event' do
    before do
      builder.where_id('MyId')
      allow(client).to receive(:send_event)
        .with(FakeWorkflow1, 'MyId', event)
        .and_return(nil)
    end

    it 'asks the client to send the event' do
      builder.send_event(event)
      expect(client).to have_received(:send_event)
    end

    it 'returns itself' do
      expect(builder.send_event(event)).to eq(builder)
    end
  end

  describe '#kill' do
    before do
      builder.where_id('MyId')
      allow(client).to receive(:kill_workflow)
        .with(FakeWorkflow1, 'MyId')
        .and_return(nil)
    end

    it 'asks the client to stop the workflow' do
      builder.kill
      expect(client).to have_received(:kill_workflow)
    end

    it 'returns itself' do
      expect(builder.kill).to eq(builder)
    end
  end

  describe '#pause' do
    before do
      builder.where_id('MyId')
      allow(client).to receive(:pause_workflow)
        .with(FakeWorkflow1, 'MyId')
        .and_return(nil)
    end

    it 'asks the client to pause the workflow' do
      builder.pause
      expect(client).to have_received(:pause_workflow)
    end

    it 'returns itself' do
      expect(builder.pause).to eq(builder)
    end
  end

  describe '#resume' do
    before do
      builder.where_id('MyId')
      allow(client).to receive(:resume_workflow)
        .with(FakeWorkflow1, 'MyId')
        .and_return(nil)
    end

    it 'asks the client to resume the workflow' do
      builder.resume
      expect(client).to have_received(:resume_workflow)
    end

    it 'returns itself' do
      expect(builder.resume).to eq(builder)
    end
  end

  def setup_client
    allow(Zenaton::Client).to receive(:instance).and_return(client)
  end
end
