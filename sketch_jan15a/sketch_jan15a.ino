#include "HX711.h"

// Capteur 1
#define DT1 5
#define SCK1 4

// Capteur 2
#define DT2 3
#define SCK2 2

HX711 scale1;
HX711 scale2;

// Valeurs à calibrer
float calibration_factor1 = -7050;  
float calibration_factor2 = -7050;

void setup() {
  Serial.begin(9600);

  scale1.begin(DT1, SCK1);
  scale2.begin(DT2, SCK2);

  scale1.set_scale(calibration_factor1);
  scale2.set_scale(calibration_factor2);

  scale1.tare(); // remise à zéro
  scale2.tare();

  Serial.println("Balance prête !");
}

void loop() {
  float poids1 = scale1.get_units(5);
  float poids2 = scale2.get_units(5);

  float poids_total = poids1 + poids2;

  Serial.print("Capteur 1: ");
  Serial.print(poids1);
  Serial.print(" g | Capteur 2: ");
  Serial.print(poids2);
  Serial.print(" g | TOTAL: ");
  Serial.print(poids_total);
  Serial.println(" g");

  delay(500);
}
