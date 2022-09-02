#ifndef TEMP_H
#define TEMP_H

#include <Wire.h>
#include "TMP117.h"

TMP117 temp_init();
int temp_setup(TMP117 &temp);
float temp_read(TMP117 &temp);

#endif //TEMP_H
