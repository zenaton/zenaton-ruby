# frozen_string_literal: true

RSpec.shared_examples 'WithTimestamp' do |initial_arg|
  let(:klass) { described_class }
  let(:with_timestamp) { klass.new(initial_arg) }

  describe 'timezone writer' do
    after { klass.timezone = nil }

    it 'sets the timezone class variable' do
      klass.timezone = 'America/Sao_Paulo'
      expect(klass.class_variable_get(:@@_timezone)).to \
        eq('America/Sao_Paulo')
    end

    it 'raises error if timezone is not recognized' do
      expect do
        klass.timezone = 'this is not a valid timezone'
      end.to raise_error Zenaton::ExternalError
    end
  end

  describe '_get_timestamp_or_duration' do
    subject { with_timestamp._get_timestamp_or_duration }

    context 'when there is no buffer' do
      it { is_expected.to eq [nil, nil] }
    end

    context 'when applying duration methods' do
      before { with_timestamp.seconds }

      it { is_expected.to eq [nil, 1] }
    end

    context 'when applying weekday method' do
      let(:next_monday) { Date.new(2018, 7, 13) + 3.days }

      before { with_timestamp.monday }

      around do |example|
        # 13/07/2018 was a Friday
        Timecop.freeze(Date.new(2018, 7, 13))
        example.run
        Timecop.return
      end

      it { is_expected.to eq [next_monday.to_time.to_i, nil] }
    end

    context 'when applying a timestamp' do
      before { with_timestamp.timestamp(100) }

      it { is_expected.to eq([100, nil]) }
    end

    context 'when applying an at hour' do
      let(:expected_time) { Time.parse('2018-11-04 15:10:23 EST -05:00') }

      before { with_timestamp.at('15:10:23') }

      around do |example|
        described_class.timezone = 'America/New_York'
        Timecop.freeze(Time.parse('2018-11-04 01:59:00 EDT -04:00'))
        expected_time
        example.run
        Timecop.return
        described_class.timezone = nil
      end

      it { is_expected.to eq([expected_time.to_i, nil]) }
    end

    context 'when applying a day of month' do
      let(:expected_time) { Time.zone.parse('2018-08-12 23:10:15') }

      before { with_timestamp.on_day(12) }

      around do |example|
        klass.timezone = 'Europe/Paris'
        Time.zone = 'Europe/Paris'
        Timecop.freeze(Time.zone.parse('2018-07-16 23:10:15'))
        expected_time
        example.run
        Timecop.return
        Time.zone = nil
        klass.timezone = nil
      end

      it { is_expected.to eq([expected_time.to_i, nil]) }
    end
  end
end
