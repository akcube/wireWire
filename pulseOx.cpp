#include "pulseOx.h"

max32664 pulse_init(int mfio_pin = 04, int reset_pin = 05, int rawdata_bufflen = 250) {
    max32664 mx(reset_pin, mfio_pin, rawdata_bufflen);
    return mx;
}

void load_algomode_parameters(max32664 &mx) {
    algomodeInitialiser algoParameters;
    /*  Replace the predefined values with the calibration values taken with a reference spo2 device in a controlled environt.
        Please have a look here for more information, https://pdfserv.maximintegrated.com/en/an/an6921-measuring-blood-pressure-MAX32664D.pdf
        https://github.com/Protocentral/protocentral-pulse-express/blob/master/docs/SpO2-Measurement-Maxim-MAX32664-Sensor-Hub.pdf
    */

    algoParameters.calibValSys[0] = 120;
    algoParameters.calibValSys[1] = 122;
    algoParameters.calibValSys[2] = 125;

    algoParameters.calibValDia[0] = 80;
    algoParameters.calibValDia[1] = 81;
    algoParameters.calibValDia[2] = 82;

    algoParameters.spo2CalibCoefA = 1.5958422;
    algoParameters.spo2CalibCoefB = -34.659664;
    algoParameters.spo2CalibCoefC = 112.68987;

    mx.loadAlgorithmParameters(&algoParameters);
}

int pulse_setup(max32664 &mx) {
    load_algomode_parameters(mx);
    int res = mx.hubBegin();
    const int retries = 10;
    if (res != CMD_SUCCESS) return -1;
    bool ret = mx.startBPTcalibration();
    if (!ret) return -1;
    delay(1000);
    ret = mx.configAlgoInEstimationMode();
    for (int i = 0; i < retries and !ret; i++) {
        ret = mx.configAlgoInEstimationMode();
        Serial.print(".");
        delay(10000);
    }
    if (!ret) return -1;
    return 200;
}

pulse_readings pulse_read(max32664 &mx) {
    uint8_t num_samples = mx.readSamples();
    pulse_readings ret;
    if (num_samples) {
        ret.sysBP = mx.max32664Output.sys;
        ret.diaBP = mx.max32664Output.dia;
        ret.heart_rate = mx.max32664Output.hr;
        ret.spO2 = mx.max32664Output.spo2;
    }
    return ret;
}
