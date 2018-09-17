# frozen_string_literal: true

require './spec/support/stub_http'
require 'zenaton/services/http'

RSpec.describe Zenaton::Services::Http do
  let(:http) { described_class.new }

  describe '#get' do
    let(:request) { http.get(url) }

    context 'when the request is successful' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts/1' }
      # rubocop:disable Metrics/LineLength
      let(:expected_response) do
        {
          'userId' => 1,
          'id' => 1,
          'title' => 'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
          'body' => "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
        }
      end
      # rubocop:enable Metrics/LineLength

      around do |example|
        VCR.use_cassette('get_request_200') { example.run }
      end

      it 'returns the parsed response body' do
        expect(request).to eq(expected_response)
      end
    end

    context 'when the request causes an error' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts/1001' }

      around do |example|
        VCR.use_cassette('get_request_404') { example.run }
      end

      it 'raises an internal error with parsed body as message' do
        expect { request }.to raise_error Zenaton::InternalError, '404: '
      end
    end

    context 'when there is a network error' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts/1' }

      before do
        allow(Net::HTTP).to receive(:start).and_raise(Errno::ECONNRESET)
      end

      it 'raises a connection error' do
        expect { request }.to raise_error Zenaton::ConnectionError
      end
    end
  end

  describe '#post' do
    let(:request) { http.post(url, body) }

    context 'when the request is successful' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts' }
      let(:body) do
        {
          title: 'Amazing post',
          body: 'You really should read this',
          userId: 1
        }
      end
      let(:expected_response) do
        {
          'userId' => 1,
          'id' => 101,
          'title' => 'Amazing post',
          'body' => 'You really should read this'
        }
      end

      around do |example|
        VCR.use_cassette('post_request_201') { example.run }
      end

      it 'returns the parsed response body' do
        expect(request).to eq(expected_response)
      end
    end

    context 'when the request causes an error' do
      let(:url) { 'https://jsonplaceholder.typicode.com/nonexistent' }
      let(:body) { {} }

      around do |example|
        VCR.use_cassette('post_request_404') { example.run }
      end

      it 'raises an internal error with parsed body as message' do
        expect { request }.to raise_error Zenaton::InternalError, '404: '
      end
    end

    context 'when there is a network error' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts' }
      let(:body) { {} }

      before do
        allow(Net::HTTP).to receive(:start).and_raise(Timeout::Error)
      end

      it 'raises a connection error' do
        expect { request }.to raise_error Zenaton::ConnectionError
      end
    end
  end

  describe '#put' do
    let(:request) { http.put(url, body) }

    context 'when the request is successful' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts/1' }
      let(:body) do
        {
          id: 1,
          title: 'Updated post',
          body: 'This is even better',
          userId: 1
        }
      end
      let(:expected_response) do
        {
          'userId' => 1,
          'id' => 1,
          'title' => 'Updated post',
          'body' => 'This is even better'
        }
      end

      around do |example|
        VCR.use_cassette('put_request_200') { example.run }
      end

      it 'returns the parsed response body' do
        expect(request).to eq(expected_response)
      end
    end

    context 'when the request causes an error' do
      let(:url) { 'https://jsonplaceholder.typicode.com/nonexistent' }
      let(:body) { {} }

      around do |example|
        VCR.use_cassette('put_request_404') { example.run }
      end

      it 'raises an internal error with parsed body as message' do
        expect { request }.to raise_error Zenaton::InternalError, '404: '
      end
    end

    context 'when there is a network error' do
      let(:url) { 'https://jsonplaceholder.typicode.com/posts/1' }
      let(:body) { {} }

      before do
        allow(Net::HTTP).to receive(:start).and_raise(Net::HTTPBadResponse)
      end

      it 'raises a connection error' do
        expect { request }.to raise_error Zenaton::ConnectionError
      end
    end
  end
end
