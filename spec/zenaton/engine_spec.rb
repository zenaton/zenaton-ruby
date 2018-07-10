# frozen_string_literal: true

require 'zenaton/engine'

RSpec.describe Zenaton::Engine do
  let(:engine) { described_class.instance }

  before { Singleton.__init__(described_class) }

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
  end

  describe '#processor=' do
    it 'can store a processor' do
      engine.processor = 'this should be a processor'
      expect(engine.instance_variable_get(:@processor)).to \
        eq('this should be a processor')
    end
  end

  describe '#execute' do
    let(:processor) { double(process: nil) }

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
      let(:job1) { double(handle: 'result1') }
      let(:job2) { double(handle: 'result2') }
      let(:results) { engine.execute([job1, job2]) }

      before { results }

      it 'returns the results' do
        expect(results).to eq(%w[result1 result2])
      end

      it 'does not call the processor' do
        expect(processor).not_to have_received(:process)
      end

      it 'sends `handle` to each job' do
        expect(job1).to have_received(:handle).with(no_args)
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
      let(:job1) { double(handle: 'result1') }
      let(:job2) { double(handle: 'result2') }
      let(:results) { engine.execute([job1, job2]) }

      before do
        engine.processor = processor
        results
      end

      it 'returns nothing' do
        expect(results).to be_nil
      end

      it 'tells the processor to process' do
        expect(processor).to have_received(:process).with([job1, job2], true)
      end

      it 'does not send `handle` to each job' do
        expect(job1).not_to have_received(:handle)
      end
    end
  end

  describe '#dispatch' do
    it 'responds to dispatch' do
      expect(engine).to respond_to(:dispatch)
    end
  end
end
