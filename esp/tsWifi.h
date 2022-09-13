#ifndef TS_WIFI_H
#define TS_WIFI_H

#include "ThingSpeak.h"
#include "WiFi.h"

extern WiFiClient client;

const int RETRIES = 100;

struct ts_info {
  int id;
  char *writeKey, *readKey;
};

struct wifi_info {
  char *ssid, *pass;
};

/*
 * 1 -> sysBP
 * 2 -> DiaBP
 * 3 -> heartRate
 * 4 -> temp
 * 5 -> spO2
 * 6 -> gsr
*/

ts_info ts_init(int id, char *writeKey, char *readKey);
wifi_info wf_init(char *ssid, char *pass);
int ts_wf_setup(ts_info ts, wifi_info wf);
int ts_write(ts_info ts, float sysBP, float diaBP, float heart_rate, float temp,
             float spO2, float gsr);

#endif // TS_WIFI_H
