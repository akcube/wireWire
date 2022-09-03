#include "lcd.h"

Adafruit_SSD1306 lcd_init() {
  Adafruit_SSD1306 ret(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);
  return ret;
}

int lcd_setup(Adafruit_SSD1306 &oled) {
  int retries = 100;
  for (int i = 0; i < retries and !oled.begin(SSD1306_SWITCHCAPVCC, 0x3C); i++) {
    Serial.println(F("SSD1306 allocation failed"));
    delay(500);
  }
  if (!oled.begin(SSD1306_SWITCHCAPVCC, 0x3C)) return -1;
  delay(2000); // wait for initializing
  oled.setTextSize(1);
  oled.setTextColor(WHITE);
  oled.setCursor(0, 10);
  return 200;
}

void lcd_display(Adafruit_SSD1306 &oled, float systole, float diastole, float heartRate, float temp, float spo2, float gsr) {
  String text1 = "Temp: " + String(temp) + "* C";
  String text2 = "BP: " + String(systole) + "/" + String(diastole);
  String text3 = "Pulse: " + String(heartRate);
  String text4 = "SPO2: " + String(spo2);
  String text5 = "SCR: " + String(gsr);

  int text = 10, space = 2;
  int y = 2;
  
  oled.clearDisplay();
  oled.setCursor(0, y);
  oled.println(text1);

  y += text + space;
  oled.setCursor(0, y);
  oled.println(text2);

  y += text + space;
  oled.setCursor(0, y);
  oled.println(text3);

  y += text + space;
  oled.setCursor(0, y);
  oled.println(text4);

  y += text + space;
  oled.setCursor(0, y);
  oled.println(text5);
  
  oled.display();
}
