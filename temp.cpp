#include "temp.h"

// Select the correct address setting
uint8_t ADDR_GND =  0x48;   // 1001000 
uint8_t ADDR_VCC =  0x49;   // 1001001
uint8_t ADDR_SDA =  0x4A;   // 1001010
uint8_t ADDR_SCL =  0x4B;   // 1001011

TMP117 temp_init() {
  TMP117 ret(ADDR_GND);
  return ret;
}

int temp_setup(TMP117 &temp) {
  temp.init(NULL);
  return 200;
}

float temp_read(TMP117 &temp) {
  float ret = temp.getTemperature();
  return ret;
}
