#include <Wire.h>
#include "Adafruit_MPR121.h"

const int Spectra_PIN = A1; // flex sensor

const int MPU_ADDR = 0x68; // accelerometer

const int FSR_PINS = A0; // fsr sensor

// Capacitive sensor
Adafruit_MPR121 cap = Adafruit_MPR121();
const int NUM_SENSORS = 4;
const int DROP_THRESHOLD = 5;
int  softBaseline[NUM_SENSORS];
bool wasTouched[NUM_SENSORS];

String s_data = "";

void setup() {
  Serial.begin(115200);
  delay(10);

  // ---------------------------------------------------------------------
  // Capacitive sensor from previous labs
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found - check wiring.");
    while (1) delay(10);
  }

  // Restart sensing so the chip settles, then take our own baseline per pad
  cap.writeRegister(MPR121_ECR, 0x00);
  delay(200);
  cap.writeRegister(MPR121_ECR, 0x8F);
  delay(500);

  for (int s = 0; s < NUM_SENSORS; s++) {
    long sum = 0;
    for (int i = 0; i < 20; i++) { sum += cap.filteredData(s); delay(5); }
    softBaseline[s] = sum / 20;
    wasTouched[s] = false;
  }

  Serial.println("Ready. Touch any pad (0-11).");

  // ---------------------------------------------------------------------
  // MPU sensor prov previous lab, is it necessary??
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission();
}

int16_t readAccel() {
  uint8_t highByte = Wire.read();
  uint8_t lowByte = Wire.read();
  return (int16_t)((highByte << 8) | lowByte);
}

void loop() {

  // ---------------------------------------------------------------------
  // spectra sensor
  int spectraValue = analogRead(Spectra_PIN);
  s_data += String(spectraValue) + ", ";
  
  // ---------------------------------------------------------------------
  // FSR sensor
  int fsrValue = analogRead(FSR_PINS);
  s_data += String(fsrValue) + ", ";
  
  // ---------------------------------------------------------------------
  // MPU sensor
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 6);
  s_data += String(readAccel()) + ", ";
  s_data += String(readAccel()) + ", ";
  s_data += String(readAccel()) + ", ";

  
  // ---------------------------------------------------------------------
  // MPR121 sensor
  uint16_t chipTouched = cap.touched();   // bit s = electrode s

  for (int s = 0; s < NUM_SENSORS; s++) {
    // Touch if the chip reports it OR the reading drops below our baseline
    bool chipSaysTouched = chipTouched & (1 << s);
    bool dropped = (softBaseline[s] - (int)cap.filteredData(s)) > DROP_THRESHOLD;
    bool touched = chipSaysTouched || dropped;

    if (touched && !wasTouched[s]) {
      s_data += String(s) + ", ";
    }
    wasTouched[s] = touched;
  }
/**/
  // ---------------------------------------------------------------------
  Serial.println(s_data);
  s_data = "";
  delay(200);
  
}
