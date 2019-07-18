# frozen_string_literal: true

RSpec.shared_examples 'Repeatable' do
  let(:repeatable) { described_class.new }

  describe '#repeat' do
    context 'with a valid cron expression' do
      let(:cron) { '*/1 * * * *' }

      it 'returns an instance of the repeatable class' do
        expect(repeatable.repeat(cron)).to be_a(described_class)
      end

      it 'becomes repeatable' do
        repeatable.repeat(cron)
        expect(repeatable).to be_repeatable
      end

      it 'has a scheduling' do
        repeatable.repeat(cron)
        expect(repeatable.cron).to eq(cron)
      end
    end

    context 'with second precision' do
      let(:cron) { '*/1 * * * * *' }

      it 'returns an instance of the repeatable class' do
        expect(repeatable.repeat(cron)).to be_a(described_class)
      end

      it 'becomes repeatable' do
        repeatable.repeat(cron)
        expect(repeatable).to be_repeatable
      end

      it 'has a scheduling' do
        repeatable.repeat(cron)
        expect(repeatable.cron).to eq(cron)
      end
    end

    context 'with an invalid cron expression' do
      let(:cron) { 12 }

      it 'raises an exception' do
        expect { repeatable.repeat(cron) }.to \
          raise_error Zenaton::InvalidArgumentError, /Could not parse `12'/
      end

      it 'does not become repeatable' do
        begin
          repeatable.repeat(cron)
        rescue Zenaton::InvalidArgumentError
          expect(repeatable).not_to be_repeatable
        end
      end

      it 'does not have a scheduling' do
        begin
          repeatable.repeat(cron)
        rescue Zenaton::InvalidArgumentError
          expect(repeatable.cron).to be_nil
        end
      end
    end

    context 'without any cron' do
      it 'is not repeatble' do
        expect(repeatable).not_to be_repeatable
      end

      it 'has no scheduling' do
        expect(repeatable.cron).to be_nil
      end
    end
  end
end
