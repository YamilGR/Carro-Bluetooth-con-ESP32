#include "BluetoothSerial.h"
#include <Arduino.h>
#define TRIG_PIN 17
#define ECHO_PIN 16

const int inPin1 = 22;
const int inPin2 = 21;
const int enable = 23;
const int inPin3 = 19;
const int inPin4 = 18;
const int enable2 = 5;
const int irPin1D = 4;
const int irPin2I = 15;

//Variables de tiempo
unsigned long reverseST;
const unsigned long reverseD = 500;
bool reverse = false;
bool reverseR = false;

String device_name = "ESP32 Proyecto";

// Check if Bluetooth is available
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

// Check Serial Port Profile
#if !defined(CONFIG_BT_SPP_ENABLED)
#error Serial Port Profile for Bluetooth is not available or not enabled. It is only available for the ESP32 chip.
#endif

BluetoothSerial SerialBT;

void setup() {
  Serial.begin(115200);
  Serial.setTimeout(50);
  SerialBT.begin(device_name);  //Bluetooth device name
  pinMode(inPin1, OUTPUT);
  pinMode(inPin2, OUTPUT);
  pinMode(enable, OUTPUT);
  pinMode(inPin3, OUTPUT);
  pinMode(inPin4, OUTPUT);
  pinMode(enable2, OUTPUT);
  pinMode(irPin1D, INPUT);
  pinMode(irPin2I, INPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);
  delay(1000);
}

void loop() {
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  float distance = (duration / 2.0) / 29.1;
  int irS1 = digitalRead(irPin1D);
  int irS2 = digitalRead(irPin2I);
  if (Serial.available()) {
    SerialBT.write(Serial.read());
  }
  if (SerialBT.available()) {
      while (SerialBT.available()) {
        int com = SerialBT.read();
        int dat = SerialBT.read();
        if (com == 1) {
          MotorAD(dat, distance, irS1, irS2);
        } else if (com = 2){
          MotorID(dat, irS1, irS2);
        } else{
          Serial.println("Dato invalido");
        }
       } 
  }
  delay(20);
}

void MotorAD(int speed, int distance, int ir1, int ir2){
  if (speed >= 127){
    int speedA = (speed - 126);
    digitalWrite(inPin1, HIGH);
    digitalWrite(inPin2, LOW);
    analogWrite(enable, speedA);
    digitalWrite(inPin3, HIGH);
    digitalWrite(inPin4, LOW);
    analogWrite(enable2, speedA);
    if (distance < 40){
      digitalWrite(inPin1, LOW);
      digitalWrite(inPin2, LOW);
      analogWrite(enable, 0);
      digitalWrite(inPin3, LOW);
      digitalWrite(inPin4, LOW);
      analogWrite(enable2, 0);
      }
    if (ir1 == LOW && !reverse){
      dodgeD();
    }
    if (ir2 == LOW && !reverse){
      dodgeI();
    }
    if ((ir1 == LOW && ir2 == LOW) && !reverse){
      stop();
    }
    if (reverse){
      if (millis() - reverseST >= reverseD){
        stopdodge();
      }
    }
    return;
  }
  if (speed < 127){
    int speedR = (speed - 126) * -1;
    digitalWrite(inPin1, LOW);
    digitalWrite(inPin2, HIGH);
    analogWrite(enable, speedR);
    digitalWrite(inPin3, LOW);
    digitalWrite(inPin4, HIGH);
    analogWrite(enable2, speedR);

    if (ir1 == LOW && !reverseR){
      dodgeT();
    }
    if (ir2 == LOW && !reverseR){
      dodgeT();
    }
    if ((ir1 == LOW && ir2 == LOW) && !reverse){
      stop();
    }
    if (reverseR){
      if (millis() - reverseST >= reverseD){
        stopdodge();
      }
    }
  }
  return;
}

void MotorID(int speed, int ir1, int ir2){
  if (speed >= 127){
    int speedI = (speed - 126);
    digitalWrite(inPin1, LOW);
    digitalWrite(inPin2, HIGH);
    analogWrite(enable, speedI);
    digitalWrite(inPin3, HIGH);
    digitalWrite(inPin4, LOW);
    analogWrite(enable2, speedI);

    if (ir1 == LOW && !reverse){
      dodgeD();
    }
    if (ir2 == LOW && !reverse){
      dodgeI();
    }
    if ((ir1 == LOW && ir2 == LOW) && !reverse){
      stop();
    }
    if (reverse){
      if (millis() - reverseST >= reverseD){
        stopdodge();
      }
    }
    return;
  }
  if (speed < 127){
    int speedD = (speed - 126) * -1;
    digitalWrite(inPin1, HIGH);
    digitalWrite(inPin2, LOW);
    analogWrite(enable, speedD);
    digitalWrite(inPin3, LOW);
    digitalWrite(inPin4, HIGH);
    analogWrite(enable2, speedD);

    if (ir1 == LOW && !reverse){
      dodgeD();
    }
    if (ir2 == LOW && !reverse){
      dodgeI();
    }
    if ((ir1 == LOW && ir2 == LOW) && !reverse){
      stop();
    }
    if (reverse){
      if(millis() - reverseST >= reverseD){
        stopdodge();
      }
    }
  }
  return;
}

void dodgeD(){
  reverse = true;
  reverseST = millis();
  //Acción a realizar
  digitalWrite(inPin1, LOW);
  digitalWrite(inPin2, HIGH);
  analogWrite(enable, 120);
  digitalWrite(inPin3, HIGH);
  digitalWrite(inPin4, LOW);
  analogWrite(enable2, 120);
}

void dodgeI(){
  reverse = true;
  reverseST = millis();
  //Acción a realizar
  digitalWrite(inPin1, HIGH);
  digitalWrite(inPin2, LOW);
  analogWrite(enable, 120);
  digitalWrite(inPin3, LOW);
  digitalWrite(inPin4, HIGH);
  analogWrite(enable2, 120);
}

void stopdodge(){
  reverse = false;
  reverseR = false;
  // Detener el carro
  digitalWrite(inPin1, LOW);
  digitalWrite(inPin2, LOW);
  analogWrite(enable, 0);
  digitalWrite(inPin3, LOW);
  digitalWrite(inPin4, LOW);
  analogWrite(enable2, 0);
  Serial.println("Deteniendo");
  delay(2000);
}

void dodgeT(){
  reverseR = true;
  reverseST = millis();
  //Acción a realizar
  digitalWrite(inPin1, LOW);
  digitalWrite(inPin2, HIGH);
  analogWrite(enable, 150);
  digitalWrite(inPin3, LOW);
  digitalWrite(inPin4, HIGH);
  analogWrite(enable2, 150);
}

void stop(){
  reverse = true;
  reverseST = millis();
  //Acción a realizar
  digitalWrite(inPin1, LOW);
  digitalWrite(inPin2, LOW);
  analogWrite(enable, 0);
  digitalWrite(inPin3, LOW);
  digitalWrite(inPin4, LOW);
  analogWrite(enable2, 0);
}