#include "gsr.h"
#include "pulseOx.h"
#include "tsWifi.h"
#include "temp.h"

#define STOP while(1) delay(1000);

/*config*/
//for esp32
const int mfio_pin = 4;
const int reset_pin = 5;
const int scl_pin = 22;
const int sda_pin = 21;
const int gsr_pin = 13; //HAVEN'T GOTTEN IT TO WORK ON ESP32 TILL NOW

//for arduino
/*
#define GSR_PIN A0
#define MFIO_PIN 2
#define RESET_PIN 4
#define SCL_PIN A5
#define SDA_PIN A4
*/

//and of course power and ground for both

auto mx = pulse_init(mfio_pin, reset_pin, 250);
auto tmp = temp_init();
auto ts = ts_init(1848083, "PLUM4SRVWRZJTVHL", "PBAFJJXW26IZ1YFM");
auto wf = wf_init("real", "12345678");

void setup() {
  Wire.begin();
  Serial.begin(115200);
  if (pulse_setup(mx) < 0) {
    Serial.println("Error setting up pulse ox");
    STOP;
  }
  temp_setup(tmp);
  if (ts_wf_setup(ts, wf) < 0) {
    Serial.println("Error setting up thingspeak and wifi client");
    STOP;
  }
}

void loop() {
  float gsr = gsr_read(31);
  Serial.print("GSR Reading: ");
  Serial.println(gsr);
  auto pulse_readings = pulse_read(mx);
  Serial.print("Systolic Blood Pressure: ");
  Serial.println(pulse_readings.sysBP);
  Serial.print("Diastolic Blood Pressure: ");
  Serial.println(pulse_readings.diaBP);
  Serial.print("Heartrate: ");
  Serial.println(pulse_readings.heart_rate);
  Serial.print("spO2: ");
  Serial.println(pulse_readings.spO2);
  float tempReading = temp_read(tmp);
  Serial.print("Temperature reading: ");
  Serial.println(tempReading);
  
  delay(1000);
}
