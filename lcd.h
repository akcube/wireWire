#ifndef LCD_H
#define LCD_H

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width,  in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

Adafruit_SSD1306 lcd_init();
int lcd_setup(Adafruit_SSD1306 &oled);
void lcd_display(Adafruit_SSD1306 &oled);

#endif //LCD_H
