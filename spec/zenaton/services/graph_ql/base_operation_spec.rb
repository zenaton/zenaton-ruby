# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_operation'

RSpec.describe Zenaton::Services::GraphQL::BaseOperation do
  subject(:operation) { described_class.new }

  describe '#body' do
    it 'raises a not implemented error' do
      expect { operation.body }.to \
        raise_error Zenaton::NotImplemented
    end
  end

  describe '#raw_query' do
    it 'raises a not implemented error' do
      expect { operation.raw_query }.to \
        raise_error Zenaton::NotImplemented
    end
  end

  describe '#query' do
    it 'removes duplicate spaces from query' do
      operation.define_singleton_method(:raw_query) do
        'this  that'
      end

      expect(operation.query).to eq('this that')
    end

    it 'converts line breaks to spaces' do
      operation.define_singleton_method(:raw_query) do
        "that\nthis"
      end

      expect(operation.query).to eq('that this')
    end

    it 'removes duplicate line breaks' do
      operation.define_singleton_method(:raw_query) do
        "one\n\ntwo"
      end

      expect(operation.query).to eq('one two')
    end

    it 'removes duplicate line break and space' do
      operation.define_singleton_method(:raw_query) do
        "two \n \n one"
      end

      expect(operation.query).to eq('two one')
    end
  end

  describe '#result' do
    subject(:result) { operation.result(response) }

    context 'when the response is a success' do
      let(:response) do
        {
          'data' => {
            'findWorkflow' => {
              'name' => 'FakeWorkflow2',
              'properties' => '{"o":"@zenaton#0","s":[{"a":{"@a":0,"@b":10}}]}'
            }
          }
        }
      end

      let(:expected_result) do
        {
          'findWorkflow' => {
            'name' => 'FakeWorkflow2',
            'properties' => '{"o":"@zenaton#0","s":[{"a":{"@a":0,"@b":10}}]}'
          }
        }
      end

      it 'returns the content under the data key' do
        is_expected.to eq(expected_result)
      end
    end

    context 'when the response is an error without path' do
      # rubocop:disable Metrics/LineLength
      let(:response) do
        {
          'errors' => [{
            'locations' => [{
              'column' => 0,
              'line' => 1
            }],
            'message' => 'In argument \'environmentName\': Expected type \'String!\', found null.'
          }, {
            'locations' => [{
              'column' => 0,
              'line' => 1
            }, {
              'column' => 0,
              'line' => 1
            }],
            'message' => 'Variable \'environmentName\' is never used.'
          }]
        }
      end
      # rubocop:enable Metrics/LineLength

      let(:expected_result) do
        <<~MSG
          - In argument 'environmentName': Expected type 'String!', found null.
          - Variable 'environmentName' is never used.
        MSG
      end

      it 'raises an error with formatted message' do
        expect { result }.to \
          raise_error Zenaton::ExternalError, expected_result.strip
      end
    end

    context 'when the response is an error with a path' do
      let(:response) do
        {
          'data' => {
            'createTaskSchedule' => nil
          },
          'errors' => [{
            'locations' => [{
              'column' => 0,
              'line' => 1
            }],
            'message' => 'The Cron Format String contains to many parts.',
            'path' => ['createTaskSchedule'],
            'type' => 'UNPROCESSABLE_ENTITY'
          }]
        }
      end
      let(:expected_result) do
        <<~MSG
          - ["createTaskSchedule"]: The Cron Format String contains to many parts.
        MSG
      end

      it 'raises an error with formatted message' do
        expect { result }.to \
          raise_error Zenaton::ExternalError, expected_result.strip
      end
    end
  end
end
