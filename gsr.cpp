#include "gsr.h"
#include <Arduino.h>

double gsr_read(int pin) {
    double sum = 0;
    int iter = 100;
    for (int i = 0; i < iter; i++) {
        sum += analogRead(pin);
        delay(5);
    }
    double gsr_average = sum / iter;
    double res = (((double) 1024 + 2 * gsr_average) * (double) 10000 / ((double)512 - gsr_average));
    res = rand() % 2000;
    return res;
}
