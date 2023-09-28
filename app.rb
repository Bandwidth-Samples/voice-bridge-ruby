require 'sinatra'
require 'bandwidth-sdk'

begin
  BW_USERNAME = ENV.fetch('BW_USERNAME')
  BW_PASSWORD = ENV.fetch('BW_PASSWORD')
  BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
  BW_VOICE_APPLICATION_ID = ENV.fetch('BW_VOICE_APPLICATION_ID')
  BW_NUMBER = ENV.fetch('BW_NUMBER')
  USER_NUMBER = ENV.fetch('USER_NUMBER')
  LOCAL_PORT = ENV.fetch('LOCAL_PORT')
  BASE_CALLBACK_URL = ENV.fetch('BASE_CALLBACK_URL')
rescue StandardError
  puts 'Please set the environmental variables defined in the README'
  exit(-1)
end

set :port, LOCAL_PORT

Bandwidth.configure do |config| # Configure Basic Auth
  config.username = BW_USERNAME
  config.password = BW_PASSWORD
end

post '/callbacks/inboundCall' do
  data = JSON.parse(request.body.read)
  call_body = Bandwidth::CreateCall.new(
    application_id: BW_VOICE_APPLICATION_ID,
    to: USER_NUMBER,
    from: BW_NUMBER,
    answer_url: "#{BASE_CALLBACK_URL}/callbacks/outboundCall",
    tag: data['callId']
  )

  calls_api_instance = Bandwidth::CallsApi.new
  calls_api_instance.create_call(BW_ACCOUNT_ID, call_body)

  speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Hold while we connect you.')
  ring = Bandwidth::Bxml::Ring.new({ duration: 30 })
  response = Bandwidth::Bxml::Response.new([speak_sentence, ring])

  return response.to_bxml
end

post '/callbacks/outboundCall' do
  data = JSON.parse(request.body.read)

  speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Hold while we connect you. We will begin to bridge you now.')
  bridge = Bandwidth::Bxml::Bridge.new(data['tag'])

  response = Bandwidth::Bxml::Response.new([speak_sentence, bridge])
  return response.to_bxml
end
