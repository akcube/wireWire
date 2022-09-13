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
  if (WiFi.status() != WL_CONNECTED)
    return -1;
  Serial.print("WiFi Connected!");
  ThingSpeak.begin(client);
  return 200;
}

/*
 * 1 -> sysBP
 * 2 -> DiaBP
 * 3 -> heartRate
 * 4 -> temp
 * 5 -> spO2
 * 6 -> gsr
 */

int ts_write(ts_info ts, float sysBP, float diaBP, float heart_rate, float temp,
             float spO2, float gsr) {
  ThingSpeak.setField(1, sysBP);
  ThingSpeak.setField(2, diaBP);
  ThingSpeak.setField(3, heart_rate);
  ThingSpeak.setField(4, temp);
  ThingSpeak.setField(5, spO2);
  ThingSpeak.setField(6, gsr);
  return ThingSpeak.writeFields(ts.id, ts.writeKey);
}
