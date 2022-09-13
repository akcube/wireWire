#include "tsWifi.h"
#include "HTTPClient.h"
#include "lcd.h"

auto ts = ts_init(1848370, "GQ2HEMW24YVRB7GR", "UORG7TMO2TM5PWRE");
auto wf = wf_init("FangaPhone", "password1");
auto oled = lcd_init();

#define STOP while(1) delay(1000);
// str = "["abc", "def", "ef"]"
void createCI(String &str) {
    HTTPClient http;
    http.begin("https://esw-onem2m.iiit.ac.in/~/in-cse/in-name/Team-26/Node-1/Data");
    http.addHeader("X-M2M-Origin", "rq9H8h:VslgQ!");
    http.addHeader("Content-Type", "application/json;ty=4");
    String toBeSent = "{\"m2m:cin\": {\"cnf\": \"application/json\",\"con\": \"[" + str + "]\"}}";
    Serial.println(toBeSent);
    int code = http.POST(toBeSent);
    Serial.print("Code sent: ");
    Serial.println(code);
    if (code == -1) {
        Serial.println("Unable to connect to the server!");
    }
    http.end();
}


void setup(){   
    Wire.begin();
    Serial.begin(9600);
    if (ts_wf_setup(ts, wf) < 0) {
        Serial.println("WError");
        STOP;
    }
    if (lcd_setup(oled) < 0) {
        Serial.println("LError");
        STOP;
    }
}

void loop(){
    if (Serial.available() > 0) {
        float input[6];
        for(int i=0; i < 6; i++){
            input[i] = Serial.parseFloat();
            Serial.println(input[i]);
        }
        lcd_display(oled, input[0], input[1], input[2], input[3], input[4], input[5]);
        ts_write(ts, input[0], input[1], input[2], input[3], input[4], input[5]);
        String toBeSent = "";
        for (int i = 0; i < 6; i++) {
          toBeSent += String(input[i]);
          if (i != 5) toBeSent += ", ";
        }
        Serial.println(toBeSent);
        createCI(toBeSent);
    }
}
