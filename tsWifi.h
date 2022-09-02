#ifndef TS_WIFI_H
#define TS_WIFI_H

#include "WiFi.h"
#include "ThingSpeak.h"

extern WiFiClient client;

const int RETRIES = 100;

struct ts_info {
  int id;
  char *writeKey, *readKey;
};

struct wifi_info {
  char *ssid, *pass;
};

ts_info ts_init(int id, char *writeKey, char *readKey);
wifi_info wf_init(char *ssid, char *pass);
int ts_wf_setup(ts_info ts, wifi_info wf);
int ts_write(ts_info ts, int field, float sensorData);

#endif //TS_WIFI_H
