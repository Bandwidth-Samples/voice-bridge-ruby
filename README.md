# Bridge
<a href="http://dev.bandwidth.com"><img src="https://s3.amazonaws.com/bwdemos/BW-VMP.png"/></a>
</div>

# Table of Contents

<!-- TOC -->

- [Description](#description)
- [Bandwidth](#bandwidth)
- [Environmental Variables](#environmental-variables)
- [Callback URLs](#callback-urls)
    - [Ngrok](#ngrok)

<!-- /TOC -->

# Description
This sample app shows how to hide (mask) a phone number through a Bandwidth phone number using Bandwidth's Bridge BXML verb. After setting up your Bandwidth Application to point to the URL running this application, anyone who calls your Bandwidth phone number will be bridged to the masked number without either party members knowing the other's phone number.

# Bandwidth
In order to use the Bandwidth API users need to set up the appropriate application at the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and create API tokens.

To create an application log into the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and navigate to the `Applications` tab.  Fill out the **New Application** form selecting the service (Voice) that the application will be used for.  All Bandwidth services require publicly accessible Callback URLs, for more information on how to set one up see [Callback URLs](#callback-urls).

For more information about API credentials see [here](https://dev.bandwidth.com/guides/accountCredentials.html#top)

# Environmental Variables
The sample app uses the below environmental variables.
```java
BANDWIDTH_ACCOUNT_ID                 // Your Bandwidth Account Id
BANDWIDTH_USERNAME                   // Your Bandwidth API Token
BANDWIDTH_PASSWORD                   // Your Bandwidth API Secret
BANDWIDTH_PHONE_NUMBER               // Your Bandwidth Phone Number
BANDWIDTH_VOICE_APPLICATION_ID       // Your Voice Application Id created in the dashboard
MASKED_PHONE_NUMBER                  // The private phone number to receive the masked call
BASE_URL                             // Your public base url
PORT                                 // The port number you wish to run the sample on
```

# Callback URLs

For a detailed introduction to Bandwidth Callbacks see https://dev.bandwidth.com/guides/callbacks/callbacks.html

Below are the callback paths:
* `/callbacks/inboundCall`
* `/callbacks/outboundCall`

## Ngrok

A simple way to set up a local callback URL for testing is to use the free tool [ngrok](https://ngrok.com/).  
After you have downloaded and installed `ngrok` run the following command to open a public tunnel to your port (`$PORT`)
```cmd
ngrok http $PORT
```
You can view your public URL at `http://127.0.0.1:{PORT}` after ngrok is running.  You can also view the status of the tunnel and requests/responses here.
