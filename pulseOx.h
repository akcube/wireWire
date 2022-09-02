#ifndef PULSEOX_H
#define PULSEOX_H

//////////////////////////////////////////////////////////////////////////////////////////
//
//    Demo code for the protoCentral MAX32664 breakout board
//
//    Author: Joice Tm
//    Copyright (c) 2020 ProtoCentral
//
//    |Max32664 pin label| Arduino Connection  |Pin Function      |
//    |----------------- |---------------------|------------------|
//    | SDA              | A4                  |  Serial Data     |
//    | SCL              | A5                  |  Serial Clock    |
//    | Vin              | 5V                  |  Power           |
//    | GND              | Gnd                 |  Gnd             |
//    | MFIO Pin         | 02                  |  MFIO            |
//    | RESET Pin        | 04                  |  Reset           |
//    |-----------------------------------------------------------|
//
//    |Max32664 pin label| ESP32 Connections   |Pin Function      |
//    |----------------- |---------------------|------------------|
//    | SDA              | D21                 |  Serial Data     |
//    | SCL              | D22                 |  Serial Clock    |
//    | Vin              | 3V3/5V              |  Power           |
//    | GND              | Gnd                 |  Gnd             |
//    | MFIO Pin         | D4                  |  MFIO            |
//    | RESET Pin        | D5                  |  Reset           |
//    |-----------------------------------------------------------|
/////////////////////////////////////////////////////////////////////////////////////////

#include <Wire.h>
#include "max32664.h"
#include <Arduino.h>

struct pulse_readings {
  float sysBP = 0, diaBP = 0, heart_rate = 0, spO2 = 0;
};

max32664 pulse_init(int mfio_pin /*= 04*/, int reset_pin /*= 05*/, int rawdata_bufflen /*= 250*/);
int pulse_setup(max32664 &mx);
pulse_readings pulse_read(max32664 &mx);


#endif //PULSEOX_H
