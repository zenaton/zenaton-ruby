# frozen_string_literal: true

require 'timecop'

RSpec.shared_examples 'WithDuration' do |initial_arg|
  let(:with_duration) { described_class.new(initial_arg) }

  context 'without timezone' do
    it 'adds seconds' do
      with_duration.seconds(2)
      expect(with_duration._get_duration).to eq(2)
    end

    it 'adds minutes' do
      with_duration.minutes(2)
      expect(with_duration._get_duration).to eq(120)
    end

    it 'adds years' do
      with_duration.years(1)
      seconds = 365 * 24 * 3_600
      seconds += 24 * 3_600 if Date.today.leap?
      expect(with_duration._get_duration).to eq(seconds)
    end

    it 'adds multiple units of time' do
      with_duration.seconds(1).minutes(2)
      expect(with_duration._get_duration).to eq(121)
    end
  end

  context 'with timezone' do
    let(:timezone) { 'America/New_York' }

    before do
      with_duration.define_singleton_method(:_timezone) { 'America/New_York' }
    end

    around do |example|
      Time.zone = timezone
      Timecop.freeze(Time.zone.parse('2018-11-04 01:59:00'))
      example.run
      Timecop.return
      Time.zone = nil
    end

    it 'calculates duration with DST' do
      duration = with_duration.days(1)._get_duration
      expect(duration).to eq(25 * 60 * 60)
    end
  end
end
