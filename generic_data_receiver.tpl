___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "CLIENT",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Generic Data Receiver",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Generic endpoint to receive requests and pass the incoming data to the common event data model",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "path",
    "displayName": "Request path",
    "simpleValueType": true,
    "help": "The request path of the incoming request, that makes the Client claim the request"
  },
  {
    "type": "TEXT",
    "name": "sec_header",
    "displayName": "value",
    "simpleValueType": true,
    "help": "Value for header \"sgtm_auth\", to handle authorization after the Client claimed the request. If incorrect, the Client returns \"Authentication for data ingestion failed\" with a 401 status code.",
    "canBeEmptyString": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

//Import required APIs
const claimRequest = require('claimRequest');
const getRequestHeader = require('getRequestHeader');
const getRequestPath = require('getRequestPath');
const logToConsole = require('logToConsole');
const returnResponse = require('returnResponse');
const setResponseBody = require('setResponseBody');
const setResponseHeader = require('setResponseHeader');
const setResponseStatus = require('setResponseStatus');
const getRequestBody = require('getRequestBody');
const JSON = require('JSON');
const getType = require('getType');
const runContainer = require('runContainer');

const requestPath = getRequestPath();
const secHeader = getRequestHeader('sgtm_auth');

//function to build response
const sendResponse = (response, headers, statusCode) => {
    setResponseStatus(statusCode);
    setResponseBody(response);
    for (const key in headers) {
        if (['expires', 'date'].indexOf(key) === -1) setResponseHeader(key, headers[key]);
    }
    returnResponse();
};

//check for request path to claim
if (requestPath === data.path) {
    claimRequest();
    const header_success = {'status':'success'};
    const header_failed = {'status':'failed'};
    //check for security header
    if (secHeader === data.sec_header) {
        let eventContainer = [];
        const requestBody = getRequestBody();
        //logic to handle single or bulk object import
        const event = (getType(requestBody) == "object" || getType(requestBody) == "array")?requestBody:JSON.parse(requestBody);
        if (getType(event) === "array") {
            eventContainer = event;
        } else {
            eventContainer.push(event);
        }
        eventContainer.forEach((events) => {
            events.event_name = "generic_event";
            runContainer(events, () => logToConsole(events));
        });
        sendResponse("Data Ingestion was successfull", header_success, 200);
    } else {
        sendResponse("Authentication for data ingestion failed", header_failed, 401);
    }
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "return_response",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "run_container",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 10.8.2023, 18:51:50


