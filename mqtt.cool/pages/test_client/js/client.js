/*
  MQTT.Cool - https://mqtt.cool

  Test Client v1.2.0

  Copyright (c) Lightstreamer Srl
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

// The MQTTCoolSession instance
var session;

// The MQTTClient instance
var mqttClient;

// The subscription counter.
var subCounter = 0;

// The message counter
var msgCounter = 0;

// The subscription map
var subscriptionsMap = {};

// The connection configuration being selected
var currentConn;

var mqttcoolHost = 'https://mqtt.cool';

var Connection = function (draft, protocol, host, port, connType) {
  this.draft = draft;
  this.protocol = protocol;
  this.host = host;
  this.port = port;
  this.connType = connType;
  this.username = null;
  this.password = null;
  this.willTopic = null;
  this.willQoS = null;
  this.willRetain = null;
  this.willMessage = null;
  this.clientId = null;
  this.cleanSession = true;
};

Connection.prototype = {
  getUrl: function () {
    return this.protocol + '://' + this.host + ':' + this.port;
  }
};

Connection.prototype.getUrl = function () {
  return this.protocol + '://' + this.host + ':' + this.port;
};

// External broker connection loaded from a JSON file
var connections = [];

function toast(msg, options) {
  $('#toastContainer')
    .append($('<div/>')
      .addClass('toast')
      .css(options)
      .hide()
      .append($('<div/>')
        .text(msg))
      .fadeIn(400)
      .delay(1750)
      .fadeOut(400, function () {
        $(this).remove();
      }));
}

function reset() {
  // Reset the counters
  subCounter = 0;
  msgCounter = 0;

  // Reset the subscription map.
  subscriptionsMap = {};

  $('#statusBtn')
    .find('span')
    .removeClass('text-success')
    .addClass('text-danger');

  $('#disconnectBtn')
    .prop('disabled', true)
    .removeClass('bg-danger')
    .removeClass('border-danger');

  // Clear the publish form from any data, if any.
  $('#publishForm')[0].reset();
  $('#publishForm').removeClass('was-validated');

  // Clear the subscription form form any data, if any.
  $('#subscriptionsForm')[0].reset();
  $('#subscriptionsForm').removeClass('was-validated');
  $('#subscriptionItem').siblings().remove();

  // Clear the message list.
  $('#message').siblings().remove();

  // Close the operations container and open the connection panel.
  $('#operations').collapse('hide');
  $('#selectBroker').collapse('show');
}

function showLoader(message) {
  $('#spinner').addClass('fa-spin');
  $('#loaderFooter').hide();
  $('#loaderMessage').text(message);
  $('#loaderModal').modal('show');
}

function hideLoader(msg) {
  if (msg) {
    $('#spinner').removeClass('fa-spin');
    $('#loaderMessage').text(msg);
    $('#loaderFooter').show();
    return;
  }
  $('#loaderModal').modal('hide');
}

function showErrorDialog(title, message) {
  $('#errorModalTitle').text(title);
  $('#errorModalMessage').text(message);
  $('#errorModal').modal('show');
}

function showConfirmDialog(title, message) {
  $('#confirmModalTitle').text(title);
  $('#confirmModalMessage').text(message);
  $('#confirmModal').modal('show');
}

function doOpenSession() {
  var mqttcoolHost = document.location.protocol == 'file:' ?
    'http://localhost:8080' : document.location.origin;
  mqttcool.openSession(mqttcoolHost, {
    onLsClient: function (lsClient) {
      lsClient.addListener({
        onStatusChange(status) {
          if (status == 'DISCONNECTED:WILL-RETRY') {
            showLoader('Trying to reconnect to the MQTT.Cool server...');
          } else if (status.indexOf('CONNECTED') != -1) {
            hideLoader();
          }
        }
      });
    },

    onConnectionSuccess: function (mqttCoolSession) {
      session = mqttCoolSession;
      hideLoader();
    },

    onConnectionFailure: function (errorType, errorCode, errorMessage) {
      console.error('Connection Failure - Error Type:', errorType);
  console.error('Connection Failure - Error Code:', errorCode);
  console.error('Connection Failure - Error Message:', errorMessage);
      hideLoader();
      var msg = errorMessage || 'Error ' + errorType;
      showErrorDialog('Connection Failure', msg);
    }
  });
}

function doConnect() {
  var conn = connections[$('#broker').val()];
  var brokerUrl = conn.getUrl();

  // Create a new MQTT client from the MQTTCoolSession instance.
  mqttClient = session.createClient(brokerUrl, conn.clientId);

  // Set the callback for handling connection lost.
  mqttClient.onConnectionLost = function (responseObject) {
    if (responseObject.errorCode != 0) {
      showErrorDialog('Connection Lost', responseObject.errorMessage);
    }
    reset();
  };

  // Set the callback for handling message delivery notification.
  mqttClient.onMessageDelivered = function (message) {
    var payload = message.payloadString;
    var text = payload.length > 10 ? payload.substring(0, 10) + '...' : payload;
    toast('Message [' + text + '] delivered', { 'background-color': 'green' });
  };

  // Set the callback for handling incoming messages.
  mqttClient.onMessageArrived = function (message) {
    messageArrived(message);
  };

  // Build the Last-Will message (only if the will topic has been provided).
  var willMessage = null;
  if (conn.willTopic) {
    willMessage = new mqttcool.Message(conn.willMessage);
    willMessage.destinationName = conn.willTopic;
    willMessage.qos = conn.willQos;
    willMessage.retained = conn.willRetain;
  }

  var connectOptions = {
    cleanSession: conn.cleanSession,
    username: conn.username,
    password: conn.password,
    willMessage: willMessage,

    onSuccess: function () {
      $('#selectBroker').collapse('hide');
      $('#statusBtn')//.removeClass('switch-off')
        .find('span')
        .removeClass('text-danger')
        .addClass('text-success');

      $('#disconnectBtn')
        .prop('disabled', false)
        .addClass('bg-danger')
        .addClass('border-danger');

      hideLoader();
    },

    onFailure: function (response) {
      hideLoader(response.errorMessage);
    }
  };

  try {
    mqttClient.connect(connectOptions);
    showLoader('Connecting to ' + brokerUrl);
  } catch (e) {
    hideLoader(e);
  }
}
function registerUser(username, password) {
  // Prepare registration data
  var registrationData = {
    username: username,
    password: password
  };

  // Convert registration data to JSON string
  var jsonData = JSON.stringify(registrationData);

  // Publish registration data to a specific MQTT topic
  mqttClient.send("user/registration", jsonData, 0, false);
}

// Event listener for registration form submission
$('#registrationForm').submit(function(event) {
  event.preventDefault(); // Prevent default form submission

  // Get username and password from the form
  var username = $('#username').val().trim();
  var password = $('#password').val().trim();

  // Validate username and password (add your validation logic here)

  // Register the user
  registerUser(username, password);
});

function messageArrived(message) {
  msgCounter++;
  var newMsg = $('#message')
    .clone()
    .prop({ id: 'msg_' + msgCounter })
    .prependTo('#messageList')
    .show();

  $('#clearMessagesBtn').prop('disabled', false);
  var now = new Date();
  var timeStamp = now.getFullYear() + '-'
    + now.getMonth() + '-'
    + now.getDate() + '  '
    + now.getUTCHours() + ':'
    + now.getUTCMinutes() + ':'
    + now.getUTCSeconds() + '.'
    + now.getUTCMilliseconds();

  newMsg.find('.msg_timestamp').append(timeStamp);
  newMsg.find('.msg_topic').append('topic: ' + message.destinationName);
  newMsg.find('.msg_payload').append(message.payloadString);
  newMsg.find('.msg_qos').append('QoS ' + message.qos);
  if (message.retained) {
    newMsg.find('.msg_retained').append('Retained');
  }
}

function doDisconnect() {
  mqttClient.disconnect();
}

function doSubscribe(topicFilter, qos) {
  var previous = subscriptionsMap[topicFilter];
  if (typeof previous !== 'undefined') {
    toast('Topic Filter already subscribed', { 'background-color': 'red' });
    return false;
  }

  mqttClient.subscribe(topicFilter, {
    qos: qos,
    onSuccess: function (/* responseObj */) {
      var subId = subCounter++;
      subscriptionsMap[topicFilter] = { id: subId, qos: qos };
      showSubscription(subId, topicFilter, qos);
      toast('Topic [' + topicFilter + '] subscribed',
        { 'background-color': 'green' });
    }
  });
}

function doUnsubscribe(topic) {
  $('#confirmBtn').click(function () {
    /* Remove the click event from the dialog */
    $('#confirmBtn').off('click');

    mqttClient.unsubscribe(topic, {
      onSuccess: function () {
        var subId = subscriptionsMap[topic].id;
        delete subscriptionsMap[topic];
        toast('Unsubscribed from [' + topic + ']',
          { 'background-color': 'yellow', 'color': 'black' });

        /* Remove the subscription from the panel */
        $('#' + mapSubscriptionId(subId)).remove();
      }
    });
    return true;
  });

  showConfirmDialog('Unsubscribe', 'Confirm to unsubscribe from ' + topic +
    '?');
}

function doPublish() {
  var s = $('#publishForm');
  if (s[0].checkValidity() == false) {
    s.addClass('was-validated');
    return false;
  }

  var topic = $('#publishingTopic').val();
  var qos = parseInt($('#publishingQos').val());
  var retain = $('#publishingRetain').is(':checked');
  var message = $('#publishingMessage').val();
  mqttClient.send(topic, message, qos, retain);
  return true;
}

function mapSubscriptionId(subId) {
  return 'sub_' + subId;
}

function showSubscription(subId, topic, qos) {
  var si = $('#subscriptionItem')
    .clone()
    .prop('id', mapSubscriptionId(subId))
    .show();

  si.find('.sub_topic').append(topic);
  si.find('.sub_qos').append('QoS ' + qos);
  si.find('.btn').click(function () {
    doUnsubscribe(topic);
  });

  $('#topicList').prepend(si);

  // Reset the subscription form.
  $('#subscribingTopic').val('');
  $('#subscribingQos').val('0');
}

function updateBrokerList() {
  // Remove current values.
  $('#broker').children().remove();

  // Add all values from the global array.
  connections.forEach(function (conn, i) {
    $('#broker')
      .append($('<option/>')
        .val(i)
        .text(conn.getUrl()));

  });

  // Trigger update of #currentbroker's text.
  $('#broker').val(0).change();
}

$(function () {
  $('#errorModal').on('hidden.bs.modal', function (/* e */) {
    // Reset the connection error message upon closing the modal instance.
    $('#errorModalMessage').text('');
    $('#errorMessageTitle').text('');
  });

  $('#broker').change(function (/* e */) {
    var selected = $(this).val();
    $('#currentBroker').text(connections[selected].getUrl());
  });

  // Populate the list of available brokers to connect to.
  $.getJSON('brokers.json', function (brokers) {
    brokers.forEach(function (broker) {
      connections.push(new Connection(false,
        broker.protocol,
        broker.host,
        broker.port,
        broker.connType));
    });

    updateBrokerList();
    prepareConnectionDialog();
  });

  $('#selectBroker').collapse('show');

  // Connect to the selected MQTT broker.
  $('#connectBtn').click(function () {
    doConnect();
  });

  $('#selectBroker').on('hidden.bs.collapse', function (/* e */) {
    $('#operations').collapse('show');
  });

  // Disconnect from the selected MQTT broker.
  $('#disconnectBtn').click(function () {
    doDisconnect();
  });

  $('#subscribeBtn').click(function () {
    var s = $('#subscriptionsForm');
    if (s[0].checkValidity() == false) {
      s.addClass('was-validated');
      return false;
    } else {
      s.removeClass('was-validated');
    }

    var topicFilter = $('#subscribingTopic').val();
    var qos = parseInt($('#subscribingQos').val());
    doSubscribe(topicFilter, qos);
  });

  // Send a message to the connected MQTT broker.
  $('#publishBtn').click(function () {
    return doPublish();
  });

  // Remove the click event from the confirmation dialog upon closing
  // through close button or close icon.
  $('#iconCloseBtn').click(function () {
    $('#confirmBtn').off('click');
  });

  $('#closeBtn').click(function () {
    $('#confirmBtn').off('click');
  });

  $('#clearMessagesBtn').click(function () {
    $('#confirmBtn').click(function () {
      /* Remove the click event from the dialog */
      $('#confirmBtn').off('click');

      $('#message').siblings().remove();

      // Disable the clear button.
      $('#clearMessagesBtn').prop('disabled', true);
    });
    showConfirmDialog('Messages', 'Do you confirm to clear the message list?');
  });

  doOpenSession();
  showLoader('Connecting to the MQTT.Cool server...');
});

function prepareConnectionDialog() {
  $('#connectionModal').on('show.bs.modal', function (e) {
    showConnection(e);
  });

  $('#dedicatedConnectionPars').on('show.bs.collapse', function () {
    fillDedicatedPars();
  });

  $('#dedicatedConnectionPars').on('hidden.bs.collapse', function () {
    $('#cleanSession').prop('checked', true).change();
    $('#clientId').val('');
    $('#willTopic').val('').change();
    $('#willQos').val(0);
    $('#willRetain').prop('checked', false);
    $('#willMessage').val('').change();
  });

  $('#dedicatedConnection').change(function () {
    // Open the form part relative to the parameters for a dedicated connection.
    $('#dedicatedConnectionPars').collapse('show');
  });

  $('#sharedConnection').change(function () {
    // Close the form part relative to the parameters for a dedicated
    // connection.
    $('#dedicatedConnectionPars').collapse('hide');
  });

  $('#cleanSession').change(function () {
    $('#clientId').prop('required', !$('#cleanSession').is(':checked'));
  });

  $('#willTopic').change(function () {
    $('#willMessage').prop('required', $(this).val().length > 0);
  });

  $('#willMessage').change(function () {
    $('#willTopic').prop('required', $(this).val().length > 0);
  });

  $('#confirmParametersBtn').click(function (e) {
    return confirmConnection(e);
  });
}

/**
 * Fill the form part relative to the connection parameters
 */
function fillDedicatedPars() {
  var cleanSession = typeof currentConn.cleanSession === 'undefined' ?
    true : currentConn.cleanSession;
  $('#cleanSession').prop('checked', cleanSession).change();
  $('#clientId').val(currentConn.clientId);
  $('#willTopic').val(currentConn.willTopic).change();
  $('#willQos').val(currentConn.willQos || 0);
  $('#willRetain').prop('checked', currentConn.willRetain);
  $('#willMessage').val(currentConn.willMessage).change();
}

function showConnection(e) {
  var sourceBtn = $(e.relatedTarget);
  var title = '';
  if (sourceBtn.prop('id') == 'addConnectionBtn') {
    title = 'Add new connection';
    currentConn = new Connection(true);
  } else {
    var selectedBroker = $('#broker').val();
    currentConn = connections[selectedBroker];
    title = 'Connection Settings for ' + currentConn.host;
  }

  // Show the dialog title
  $(e.target).find('.modal-title').text(title);

  // Show the complete broker URL.
  /*var editable = currentConnection.draft;
  var options = { 'disabled': !editable, 'required': editable };*/
  var options = {};
  $('#protocol').val(currentConn.protocol).prop(options);
  $('#host').val(currentConn.host).prop(options);
  $('#port').val(currentConn.port).prop(options);

  // Show username and password
  var username = currentConn.username;
  var password = currentConn.password;
  $('#username')
    .val(username)
    .prop('required', password && password.length > 0);

  $('#password')
    .val(password)
    .change(function () {
      $('#username').prop('required', $(this).val().length > 0);
    });

  // Initialize the connection type radio buttons
  var dedicatedId = '#dedicatedConnection';
  var sharedId = '#sharedConnection';
  var dedicatedConnType = currentConn.connType == 'dedicated';
  var connTypeId = dedicatedConnType ? dedicatedId : sharedId;
  $(connTypeId).prop('checked', true);

  $('#dedicatedConnectionPars').collapse(dedicatedConnType ? 'show' : 'hide');
}

function confirmConnection(/* e */) {
  var protocol = $('#protocol').val();
  var host = $('#host').val();
  var port = $('#port').val();
  var password = $('#password').val() || null;
  var username = $('#username').val() || null;
  var connType = $('#dedicatedConnection').is(':checked') ? 'dedicated' :
    'shared';
  var clientId = $('#clientId').val() || null;
  var cleanSession = $('#cleanSession').is(':checked');
  var willTopic = $('#willTopic').val() || null;

  var form = $('#connectionParameters');
  if (form[0].checkValidity() == false) {
    form.addClass('was-validated');
    return false;
  } else {
    form.removeClass('was-validated');
  }

  currentConn.username = username;
  currentConn.password = password;
  currentConn.connType = connType;
  currentConn.clientId = clientId;
  currentConn.cleanSession = cleanSession;
  currentConn.willTopic = willTopic;
  if (willTopic) {
    currentConn.willQos = parseInt($('#willQos').val());
    currentConn.willRetain = $('#willRetain').is(':checked');
    currentConn.willMessage = $('#willMessage').val();
  }

  currentConn.protocol = protocol;
  currentConn.host = host;
  currentConn.port = port;

  if (currentConn.draft) {
    currentConn.draft = false;
    connections.push(currentConn);
  }
  updateBrokerList();

  return true;
}

