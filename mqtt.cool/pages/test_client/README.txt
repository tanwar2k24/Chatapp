TEST CLIENT
===========

The Test Client comes with a predefined list of connection configurations, which
can be later modified while using the tool.

To update the predefined list, edit the brokers.json file by adding a new
entry or updating an existing one, as follows:

[
  ...
  {
    "host": <The address of the MQTT broker>, for example "localhost" or "iot.eclipse.org",
    "protocol": <"tcp" or "ssl">,
    "port": <The listening port of the MQTT broker, for example "1883">
    "connType": <"shared" or "dedicated">
  },
  ...
]
