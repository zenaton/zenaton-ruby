# frozen_string_literal: true

RSpec.shared_examples 'WithTimestamp' do |initial_arg|
  let(:klass) { described_class }
  let(:with_timestamp) { klass.new(initial_arg) }

  describe 'timezone writer' do
    it 'sets the timezone class variable' do
      klass.timezone = 'America/Sao_Paulo'
      expect(klass.class_variable_get(:@@timezone)).to \
        eq('America/Sao_Paulo')
    end

    it 'raises error if timezone is not recognized' do
      expect do
        klass.timezone = 'this is not a valid timezone'
      end.to raise_error Zenaton::ExternalError
    end
  end
end
