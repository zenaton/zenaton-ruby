# frozen_string_literal: true

require 'zenaton/engine'

RSpec.describe Zenaton::Engine do
  let(:engine) { described_class.instance }
  let(:processor) do
    instance_double(Zenaton::Processor, process: nil)
  end
  let(:client) do
    instance_double(Zenaton::Client, start_workflow: nil)
  end
  let(:task) do
    instance_double(
      Zenaton::Task,
      handle: 'result1'
    )
  end
  let(:workflow) do
    instance_double(
      Zenaton::Workflow,
      handle: 'result2'
    )
  end
  let(:invalid_job) { Object.new }

  before do
    setup_engine
    setup_task_double
    setup_worflow_double
  end

  describe 'initialization' do
    it 'is a singleton class' do
      engine2 = described_class.instance
      expect(engine).to eq(engine2)
    end

    it 'cannot be instantiated' do
      expect { described_class.new }.to \
        raise_error NoMethodError, /private method `new' called/
    end

    it 'stores a client and a processor as instance variables' do
      expect(engine.instance_variables).to eq(%i[@client @processor])
    end

    it 'sets the processor to nil' do
      expect(engine.instance_variable_get(:@processor)).to be_nil
    end

    it 'initializes a new client' do
      expect(engine.instance_variable_get(:@client)).to eq(client)
    end
  end

  describe '#processor=' do
    it 'can store a processor' do
      engine.processor = processor
      expect(engine.instance_variable_get(:@processor)).to \
        eq(processor)
    end
  end

  describe '#execute' do
    context 'when using invalid jobs' do
      it 'raise an invalid argument error' do
        expect { engine.execute([invalid_job]) }.to \
          raise_error Zenaton::InvalidArgumentError
      end
    end

    context 'when there are no processor nor jobs to process' do
      let(:results) { engine.execute([]) }

      before { results }

      it 'returns an empty array' do
        expect(results).to eq([])
      end

      it 'does not call the processor' do
        expect(processor).not_to have_received(:process)
      end
    end

    context 'when there are no processor but jobs to process' do
      let(:results) { engine.execute([task, workflow]) }

      before { results }

      it 'returns the results' do
        expect(results).to eq(%w[result1 result2])
      end

      it 'does not call the processor' do
        expect(processor).not_to have_received(:process)
      end

      it 'sends `handle` to tasks' do
        expect(task).to have_received(:handle).with(no_args)
      end

      it 'sends `handle` to workflows' do
        expect(workflow).to have_received(:handle).with(no_args)
      end
    end

    context 'when there is a processor but no jobs to process' do
      let(:results) { engine.execute([]) }

      before do
        engine.processor = processor
        results
      end

      it 'returns an empty array' do
        expect(results).to eq([])
      end

      it 'does not call the processor' do
        expect(processor).not_to have_received(:process)
      end
    end

    context 'when there is a  processor and jobs to process' do
      let(:results) { engine.execute([task, workflow]) }

      before do
        engine.processor = processor
        results
      end

      it 'returns nothing' do
        expect(results).to be_nil
      end

      it 'tells the processor to process' do
        expect(processor).to \
          have_received(:process).with([task, workflow], true)
      end

      it 'does not send `handle` to tasks' do
        expect(task).not_to have_received(:handle)
      end

      it 'does not send `handle` to workflows' do
        expect(workflow).not_to have_received(:handle)
      end
    end
  end

  describe '#dispatch' do
    context 'when using invalid jobs' do
      it 'raise an invalid argument error' do
        expect { engine.execute([invalid_job]) }.to \
          raise_error Zenaton::InvalidArgumentError
      end
    end

    context 'when there is no processor and no jobs' do
      let(:results) { engine.dispatch([]) }

      before { results }

      it 'returns nothing' do
        expect(results).to be_nil
      end
    end

    context 'when there is a processor but no jobs' do
      let(:results) { engine.dispatch([]) }

      before do
        engine.processor = processor
        results
      end

      it 'returns nothing' do
        expect(results).to be_nil
      end

      it 'does not tell the processor to process' do
        expect(processor).not_to have_received(:process)
      end
    end

    context 'when there is no processor but there are jobs' do
      let(:results) { engine.dispatch([task, workflow]) }

      before { results }

      it 'returns nothing' do
        expect(results).to be_nil
      end

      it 'calls handle on task' do
        expect(task).to have_received(:handle).with(no_args)
      end

      it 'sends workflows to the client' do
        expect(client).to have_received(:start_workflow).with(workflow)
      end
    end

    context 'when there is a processor and jobs' do
      let(:results) { engine.dispatch([task, workflow]) }

      before do
        engine.processor = processor
        results
      end

      it 'returns nothing' do
        expect(results).to be_nil
      end

      it 'does not call handle on jobs' do
        expect(task).not_to have_received(:handle)
      end

      it 'does not send workflows to the client' do
        expect(client).not_to have_received(:start_workflow)
      end

      it 'send the jobs to the processor' do
        expect(processor).to \
          have_received(:process).with([task, workflow], false)
      end
    end
  end

  def setup_engine
    Singleton.__init__(described_class)
    allow(Zenaton::Client).to receive(:instance).and_return(client)
  end

  def setup_task_double
    allow(task).to receive(:is_a?).with(Zenaton::Workflow).and_return(false)
    allow(task).to receive(:is_a?).with(Zenaton::Task).and_return(true)
  end

  def setup_worflow_double
    allow(workflow).to receive(:is_a?).with(Zenaton::Task).and_return(false)
    allow(workflow).to receive(:is_a?).with(Zenaton::Workflow).and_return(true)
  end
end
