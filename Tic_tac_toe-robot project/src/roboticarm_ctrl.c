#include <Servo.h>
#include <AccelStepper.h>
#include <string.h>
const int stepPin = 3;   // stepsignal pin(PWM)
const int dirPin = 8;    // dirsignal pin(I/O)
const int stepper_max = 870;  //the maximum is 870 steps
const int servo_bmin = 0;
const int servo_bmax = 65;        //record the max and min degrees of each servo
const int servo_cmin = 0;         //note1: servo_a closes at 90 and opens at 0
const int servo_cmax = 90;       //note2: servo_d should be stuck in sth. when operating
const int servo_dmin = 0;         //note3: 
const int servo_dmax = 180;

Servo servo_b,servo_c,servo_d;//define the servos
AccelStepper stepper(1, stepPin, dirPin);


int posarray[4]={0,0,0,0};      //record the degrees of the servos
int motorpos[3][3][4]={{{0,10,25,110},{350,16,30,90},{350,60,60,85}},{{300,0,20,135},{600,25,34,90},{600,65,90,90}},{{400,15,30,146},{870,25,34,90},{870,65,90,90}}};
void setup() {
//set up the servo pins
  servo_b.attach(5);
  servo_c.attach(6);
  servo_d.attach(9);
  Serial.begin(9600);
  servo_b.write(0);
  servo_c.write(0);
  servo_d.write(90);
  stepper.setMaxSpeed(300);        // maxspeed
  stepper.setAcceleration(100);     // accleration
  stepper.setCurrentPosition(0);   // set the initial position


}

void loop() {
  if (Serial.available()>0){
    //char armcmd = Serial.read();
    //if (sizeof(armcmd) <= 10){
    //  armcmd1(armcmd);
    String input = Serial.readStringUntil('\n');
    input.trim();
    pycmd(input);
    //}
  }

}
void armcmd1(char armcmd){
  extern int posarray[4];
  int servodata = Serial.parseInt();
  
  switch(armcmd){
    case 'a':
      if (servodata<=stepper_max){
        posarray[0]=servodata;
        stepper.moveTo(servodata);
        stepper.runToPosition();
        delay(50);
        Serial.println("set stepper value");
        Serial.print(servodata);
        break;
        }
    case 'b':
      if (servodata>=servo_bmin && servodata<=servo_bmax){
        posarray[1]=servodata;
        servo_b.write(posarray[1]);
        delay(50);
        Serial.println("set servo_b value");
        Serial.print(servodata);
        break;
        }
    case 'c':
      if (servodata>=servo_cmin && servodata<=servo_cmax){
        posarray[2]=servodata;
        servo_c.write(posarray[2]);
        delay(50);
        Serial.println("set servo_c value");
        Serial.print(servodata);
        break;
        }
    case 'd':
      if (servodata>=servo_dmin && servodata<=servo_dmax){
        posarray[3]=servodata;
        servo_d.write(posarray[3]);
        delay(50);
        Serial.println("set servo_d value");
        Serial.print(servodata);
        break;
        }
    case 'k':
      Serial.println("Current stepper position:");
      Serial.print(posarray[0]);
      Serial.println("Current servo position:");
      Serial.println(posarray[1]);
      Serial.println(posarray[2]);
      Serial.println(posarray[3]);
      break;
    case 'r':
      stepper.moveTo(0);
      stepper.runToPosition();
      servo_b.write(0);
      servo_c.write(0);
      servo_d.write(90);
      


    }
}

void pycmd(String pycmd1){
  int a, b;
  int index = pycmd1.indexOf(','); // 查找逗号的位置
  reset();
  if (index != -1) { // 如果找到逗号
    String part1 = pycmd1.substring(0, index); // 提取逗号前的部分
    String part2 = pycmd1.substring(index + 1); // 提取逗号后的部分
    stepper.moveTo(motorpos[part1.toInt()][part2.toInt()][0]);
    stepper.runToPosition();
    servo_b.write(motorpos[part1.toInt()][part2.toInt()][1]);
    servo_d.write(motorpos[part1.toInt()][part2.toInt()][3]);
    servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]);
    Serial.println("success!");
  }
}
void reset(){
  servo_c.write(0);
  servo_b.write(0);
  servo_d.write(90);
  stepper.moveTo(0);
  stepper.runToPosition();
}