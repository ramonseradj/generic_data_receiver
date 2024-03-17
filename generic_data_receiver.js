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
