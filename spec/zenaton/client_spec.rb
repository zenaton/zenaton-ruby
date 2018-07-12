# frozen_string_literal: true

require 'zenaton/client'
require 'fakes/version'

RSpec.describe Zenaton::Client do
  let(:client) { described_class.instance }
  let(:http) { instance_double(Zenaton::Services::Http, post: nil) }
  let(:workflow) do
    instance_double(
      Zenaton::Interfaces::Workflow,
      id: custom_id,
      class: Zenaton::Interfaces::Workflow
    )
  end

  before do
    setup_client
  end

  describe '::init' do
    let(:instance) { described_class.init('AppId', 'SecretToken', 'AppEnv') }

    before { instance }

    it 'returns the instance of the class' do
      expect(instance).to eq(client)
    end

    it 'sets the app id' do
      expect(instance.instance_variable_get(:@app_id)).to eq('AppId')
    end

    it 'sets the api token' do
      expect(instance.instance_variable_get(:@api_token)).to eq('SecretToken')
    end

    it 'sets the app environment' do
      expect(instance.instance_variable_get(:@app_env)).to eq('AppEnv')
    end
  end

  describe 'initialization' do
    it 'there is only a single instance of the class' do
      client2 = described_class.instance
      expect(client).to eq(client2)
    end

    it 'cannot be initialized' do
      expect { described_class.new }.to \
        raise_error NoMethodError, /private method `new' called/
    end

    it 'stores an instance of the http service as an instance variable' do
      expect(client.instance_variable_get(:@http)).to eq(http)
    end
  end

  describe '#worker_url' do
    context 'with environment variables but no instance variables set' do
      around do |example|
        ENV['ZENATON_WORKER_URL'] = 'http://192.168.1.1'
        ENV['ZENATON_WORKER_PORT'] = '42'
        example.run
        ENV.delete('ZENATON_WORKER_URL')
        ENV.delete('ZENATON_WORKER_PORT')
      end

      it 'returns the worker url with params' do
        url = client.worker_url('my_resource', 'myParam=1')
        expect(url).to \
          eq('http://192.168.1.1:42/api/v_newton/my_resource?myParam=1')
      end
    end

    context 'with environment and instances variables set' do
      before { described_class.init('AppId', 'ApiToken', 'AppEnv') }

      around do |example|
        ENV['ZENATON_WORKER_URL'] = 'http://192.168.1.1'
        ENV['ZENATON_WORKER_PORT'] = '42'
        example.run
        ENV.delete('ZENATON_WORKER_URL')
        ENV.delete('ZENATON_WORKER_PORT')
      end

      it 'returns the worker url with params and app env' do
        url = client.worker_url('my_resource', 'myParam=1')
        expect(url).to \
          eq('http://192.168.1.1:42/api/v_newton/my_resource?app_env=AppEnv&app_id=AppId&myParam=1')
      end
    end

    context 'with instances variables but no environment variables set' do
      before { described_class.init('AppId', 'ApiToken', 'AppEnv') }

      it 'returns the default worker url with params and app env' do
        url = client.worker_url('my_resource', 'myParam=1')
        expect(url).to \
          eq('http://localhost:4001/api/v_newton/my_resource?app_env=AppEnv&app_id=AppId&myParam=1')
      end
    end

    context 'with no environment nor instances variables set' do
      it 'returns the default worker url with params' do
        url = client.worker_url('my_resource', 'myParam=1')
        expect(url).to \
          eq('http://localhost:4001/api/v_newton/my_resource?myParam=1')
      end
    end
  end

  describe '#website_url' do
    before { described_class.init('AppId', 'ApiToken', 'AppEnv') }

    context 'with environment variables set' do
      around do |example|
        ENV['ZENATON_API_URL'] = 'http://192.168.1.1'
        example.run
        ENV.delete('ZENATON_API_URL')
      end

      it 'returns the website url with params and api token' do
        url = client.website_url('my_resource', 'myParam=1')
        expect(url).to \
          eq('http://192.168.1.1/my_resource?api_token=ApiToken&app_env=AppEnv&app_id=AppId&myParam=1')
      end
    end

    context 'with no environment variables set' do
      it 'returns the default website url with params and api token' do
        url = client.website_url('my_resource', 'myParam=1')
        expect(url).to \
          eq('https://zenaton.com/api/v1/my_resource?api_token=ApiToken&app_env=AppEnv&app_id=AppId&myParam=1')
      end
    end
  end

  describe '#start_workflow' do
    let(:start_workflow) { client.start_workflow(workflow) }
    let(:start_version_workflow) { client.start_workflow(version) }
    let(:version) { FakeVersion.new(1, 2, 3) }
    let(:expected_url) { 'http://localhost:4001/api/v_newton/instances?' }
    let(:expected_hash) do
      {
        'programming_language' => 'Ruby',
        'canonical_name' => nil,
        'name' => 'Zenaton::Interfaces::Workflow',
        'data' => '{"hard_coded":"json"}',
        'custom_id' => nil
      }
    end

    context 'with an integer custom id' do
      let(:custom_id) { 123 }

      it 'sends the custom id as a string' do
        start_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('custom_id' => '123'))
      end
    end

    context 'with an string custom id' do
      let(:custom_id) { 'MyWorkflowId' }

      it 'sends the custom id' do
        start_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('custom_id' => 'MyWorkflowId'))
      end
    end

    context 'with an invalid custom id type' do
      let(:custom_id) { {} }

      it 'raises an error' do
        expect { start_workflow }.to \
          raise_error Zenaton::InvalidArgumentError
      end
    end

    context 'with a custom id too long' do
      let(:custom_id) { 'a' * 300 }

      it 'raises an error' do
        expect { start_workflow }.to \
          raise_error Zenaton::InvalidArgumentError
      end
    end

    context 'without a custom id' do
      let(:custom_id) { nil }

      it 'sends a post request to the http client' do
        start_workflow
        expect(http).to have_received(:post).with(expected_url, expected_hash)
      end
    end

    context 'with a version workflow' do
      it 'sends the version class name as the canonical name' do
        start_version_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('canonical_name' => 'FakeVersion'))
      end

      it 'sends the workflow name as the name' do
        start_version_workflow
        expect(http).to have_received(:post)
          .with(expected_url, hash_including('name' => 'Workflow2'))
      end
    end
  end

  def setup_client
    Singleton.__init__(described_class)
    allow(Zenaton::Services::Http).to receive(:new).and_return(http)
  end
end
