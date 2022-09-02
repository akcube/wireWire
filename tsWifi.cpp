#include "tsWifi.h"

WiFiClient client;

ts_info ts_init(int id, char *writeKey, char *readKey) {
  ts_info ret;
  ret.id = id;
  ret.writeKey = writeKey;
  ret.readKey = readKey;

  return ret;
}

wifi_info wf_init(char *ssid, char *pass) {
  wifi_info ret;
  ret.ssid = ssid;
  ret.pass = pass;

  return ret;
}

int ts_wf_setup(ts_info ts, wifi_info wf) {
  WiFi.begin(wf.ssid, wf.pass);
  for (int i = 0; i < RETRIES and WiFi.status() != WL_CONNECTED; i++) {
    Serial.print(".");
    delay(500);
  }
  if (WiFi.status() != WL_CONNECTED) return -1;
  ThingSpeak.begin(client);
  return 200;
}

int ts_write(ts_info ts, int field, float sensorData) {
  return ThingSpeak.writeField(ts.id, field, sensorData, ts.writeKey);
}
