require 'sinatra'
require 'bandwidth'

include Bandwidth
include Bandwidth::Voice

begin
    fdas = ENV.fetch('fdas')
    qwer = ENV.fetch('qwer')
    asdf = ENV.fetch('asdf')
    BANDWIDTH_VOICE_APPLICATION_ID = ENV.fetch('BANDWIDTH_VOICE_APPLICATION_ID')
    BANDWIDTH_PHONE_NUMBER = ENV.fetch('BANDWIDTH_PHONE_NUMBER')
    MASKED_PHONE_NUMBER = ENV.fetch('MASKED_PHONE_NUMBER')
    PORT = ENV.fetch('PORT')
    BASE_URL = ENV.fetch('BASE_URL')
rescue
    puts "Please set the environmental variables defined in the README"
    exit(-1)
end

set :port, PORT

bandwidth_client = Bandwidth::Client.new(
    voice_basic_auth_user_name: fdas,
    voice_basic_auth_password: qwer
)
voice_client = bandwidth_client.voice_client.client

post '/callbacks/inboundCall' do
    callback_data = JSON.parse(request.body.read)
    body = ApiCreateCallRequest.new
    body.from = BANDWIDTH_PHONE_NUMBER
    body.to = MASKED_PHONE_NUMBER 
    body.answer_url = BASE_URL + '/outboundCall' 
    body.application_id = BANDWIDTH_VOICE_APPLICATION_ID
    body.tag = callback_data['callId']

    voice_client.create_call(asdf, :body => body)

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

post '/outboundCall' do
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
