int red_pin = 3;
int green_pin = 5;
int blue_pin = 6;
byte bytes[3];
int valid_data;
int time_tt;

void setup() {
  Serial.begin(9600);
//  time_tt = millis();
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) // if there is data to read
  {
    Serial.readBytes(bytes, 3);
//    time_tt = millis();
    
    analogWrite(red_pin, bytes[0]); 
    analogWrite(green_pin, bytes[1]); 
    analogWrite(blue_pin, bytes[2]);  
  }
 
//  if (time_tt - millis() > 2000) {
//    analogWrite(red_pin, 255); 
//    analogWrite(green_pin, 255); 
//    analogWrite(blue_pin, 255); 
//    return;
//  }
}

