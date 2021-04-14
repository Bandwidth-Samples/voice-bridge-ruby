require 'sinatra'
require 'bandwidth'

include Bandwidth
include Bandwidth::Voice

begin
    BW_USERNAME = ENV.fetch('BW_USERNAME')
    BW_PASSWORD = ENV.fetch('BW_PASSWORD')
    BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
    BW_VOICE_APPLICATION_ID = ENV.fetch('BW_VOICE_APPLICATION_ID')
    INBOUND_NUMBER = ENV.fetch('INBOUND_NUMBER')
    OUTBOUND_NUMBER = ENV.fetch('OUTBOUND_NUMBER')
    LOCAL_PORT = ENV.fetch('LOCAL_PORT')
    BASE_CALLBACK_URL = ENV.fetch('BASE_CALLBACK_URL')
rescue
    puts "Please set the environmental variables defined in the README"
    exit(-1)
end

set :port, LOCAL_PORT

bandwidth_client = Bandwidth::Client.new(
    voice_basic_auth_user_name: BW_USERNAME,
    voice_basic_auth_password: BW_PASSWORD
)
voice_client = bandwidth_client.voice_client.client

post '/callbacks/inboundCall' do
    callback_data = JSON.parse(request.body.read)
    body = ApiCreateCallRequest.new
    body.from = INBOUND_NUMBER
    body.to = OUTBOUND_NUMBER 
    body.answer_url = BASE_CALLBACK_URL + '/callbacks/outboundCall' 
    body.application_id = BW_VOICE_APPLICATION_ID
    body.tag = callback_data['callId']

    voice_client.create_call(BW_ACCOUNT_ID, :body => body)

    response = Bandwidth::Voice::Response.new()
    speak_sentence = Bandwidth::Voice::SpeakSentence.new({
        :sentence => "Hold while we connect you."
    })
    ring = Bandwidth::Voice::Ring.new({
        :duration => 30
    })

    response.push(speak_sentence)
    response.push(ring)
    return response.to_bxml()
end

post '/callbacks/outboundCall' do
    callback_data = JSON.parse(request.body.read)

    response = Bandwidth::Voice::Response.new()
    speak_sentence = Bandwidth::Voice::SpeakSentence.new({
        :sentence => "Hold while we connect you. We will begin to bridge you now."
    })
    bridge = Bandwidth::Voice::Bridge.new({
        :call_id => callback_data['tag']
    })

    response.push(speak_sentence)
    response.push(bridge)
    return response.to_bxml()
end
