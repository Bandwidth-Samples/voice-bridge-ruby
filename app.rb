require 'sinatra'
require 'bandwidth-sdk'

begin
  BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
  BW_CLIENT_ID = ENV.fetch('BW_CLIENT_ID')
  BW_CLIENT_SECRET = ENV.fetch('BW_CLIENT_SECRET')
  BW_VOICE_APPLICATION_ID = ENV.fetch('BW_VOICE_APPLICATION_ID')
  BW_NUMBER = ENV.fetch('BW_NUMBER')
  USER_NUMBER = ENV.fetch('USER_NUMBER')
  BASE_CALLBACK_URL = ENV.fetch('BASE_CALLBACK_URL')
  LOCAL_PORT = Integer(ENV.fetch('LOCAL_PORT'))
rescue StandardError
  puts 'Please set the environmental variables defined in the README'
  exit(-1)
end

set :port, LOCAL_PORT
set :host_authorization, permitted_hosts: []

Bandwidth.configure do |config|
  config.client_id = BW_CLIENT_ID
  config.client_secret = BW_CLIENT_SECRET
end

def parse_body
  data = JSON.parse(request.body.read)
  halt 400 unless data.is_a?(Hash)
  data
rescue JSON::ParserError
  halt 400
end

post '/callbacks/inbound/voice' do
  data = parse_body
  halt 400 unless data['eventType'] == 'initiate'

  call_body = Bandwidth::CreateCall.new(
    application_id: BW_VOICE_APPLICATION_ID,
    to: USER_NUMBER,
    from: BW_NUMBER,
    answer_url: "#{BASE_CALLBACK_URL}/callbacks/outbound/voice",
    tag: data['callId']
  )

  verbs = begin
    Bandwidth::CallsApi.new.create_call(BW_ACCOUNT_ID, call_body)
    [
      Bandwidth::Bxml::SpeakSentence.new('Hold while we connect you.'),
      Bandwidth::Bxml::Ring.new({ duration: 30 })
    ]
  rescue StandardError => e
    warn "Failed to create call: #{e.message}"
    [
      Bandwidth::Bxml::SpeakSentence.new('An error occurred. Ending call.'),
      Bandwidth::Bxml::Hangup.new
    ]
  end

  content_type 'application/xml'
  Bandwidth::Bxml::Response.new(verbs).to_bxml
end

post '/callbacks/outbound/voice' do
  data = parse_body

  response = Bandwidth::Bxml::Response.new

  case data['eventType']
  when 'answer'
    speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Hold while we connect you. We will begin to bridge you now.')
    bridge = Bandwidth::Bxml::Bridge.new(data['tag'])
    response.add_verbs([speak_sentence, bridge])
  when 'disconnect'
    puts "Call #{data['callId']} has disconnected"
  else
    puts "Unexpected event type #{data['eventType']} received"
  end

  content_type 'application/xml'
  response.to_bxml
end
