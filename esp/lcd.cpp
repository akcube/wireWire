#include "lcd.h"

Adafruit_SSD1306 lcd_init() {
  Adafruit_SSD1306 ret(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);
  return ret;
}

int lcd_setup(Adafruit_SSD1306 &oled) {
  int retries = 100;
  for (int i = 0; i < retries and !oled.begin(SSD1306_SWITCHCAPVCC, 0x3C);
       i++) {
    Serial.println(F("SSD1306 allocation failed"));
    delay(500);
  }
  delay(2000); // wait for initializing
  oled.setTextSize(1);
  oled.setTextColor(WHITE);
  oled.setCursor(0, 10);
  return 200;
}

void lcd_display(Adafruit_SSD1306 &oled, float systole, float diastole,
                 float heartRate, float temp, float spo2, float gsr) {

  oled.clearDisplay();
  oled.display();
  int text = 10, space = 2;
  int y = 2;
  oled.clearDisplay();
  oled.display();
  oled.setCursor(0, y);
  oled.display();
  oled.print("Temp: ");
  oled.println(temp);
  oled.display();

  y += text + space;
  oled.setCursor(0, y);
  oled.display();
  oled.print("BP: ");
  oled.print(systole);
  oled.print("/");
  oled.println(diastole);
  oled.display();

  y += text + space;
  oled.setCursor(0, y);
  oled.display();
  oled.print("HR: ");
  oled.println(heartRate);
  oled.display();

  y += text + space;
  oled.setCursor(0, y);
  oled.display();
  oled.print("SpO2: ");
  oled.println(spo2);
  oled.display();

  y += text + space;
  oled.setCursor(0, y);
  oled.display();
  oled.print("GSR: ");
  oled.println(gsr);
  oled.display();
  delay(2000);
}
