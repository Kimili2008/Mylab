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
const int elementPin = 10; // 定义连接电磁铁的引脚
Servo servo_b,servo_c,servo_d;//define the servos
AccelStepper stepper(1, stepPin, dirPin);
int status = 0;

int posarray[4]={0,0,0,0};      //record the degrees of the servos

int motorpos[3][3][4]={{{0,10,30,150},{300,10,20,145},{400,25,35,155}},{{350,25,35,90},{620,25,30,90},{870,20,30,90}},{{350,65,70,90},{630,65,70,90},{870,65,60,90}}};
int stonepos[2][5][4]={{{0,10,25,90},{0,40,50,75},{0,20,34,63},{200,0,30,30}},{{870,40,50,130},{870,35,50,147},{750,25,40,145},{870,20,35,155},{750,10,35,160}}}; // the first one contains the pos of white stones //the second one contains the pos of black stones
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
  if (Serial.available()>0) {
    //char armcmd = Serial.read();
    //if (sizeof(armcmd) <= 10){
      //armcmd1(armcmd);
    String input = Serial.readStringUntil('\n');
    input.trim();
    pycmd(input);
    //}
  }  

  
  if (status == 1){
    digitalWrite(elementPin,HIGH);
  }
  else{
    digitalWrite(elementPin, LOW);
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
      servo_c.write(0);
      servo_d.write(90);
      stepper.moveTo(0);
      stepper.runToPosition();
      servo_b.write(0);
      break;
    case 'q':
      status = 1;
      break;
    case 'w':
      status = 0;
      break;

    }
}

void pycmd(String pycmd1){   //(消息传输格式，分为三种消息，第一种是reset消息，第二种是移动位置消息;e.g."1,1"表示机械臂把棋子放到1，1位置,第三种格式是抓取位置消息，"1；2"指代白色方的第二个棋子)
  int a, b;
  int indexabn = pycmd1.indexOf('<');  //< is for retract
  int indexn = pycmd1.indexOf('>');    //> is for normal players
  int index = pycmd1.indexOf(','); // 查找逗号的位置
  int index1 = pycmd1.indexOf(';');
  //------------------------------------------------------------
  if (indexn != -1){
      if (index != -1) { // 如果找到逗号
        String part1 = pycmd1.substring(1, index); // 提取逗号前的部分
        String part2 = pycmd1.substring(index + 1); // 提取逗号后的部分
        if (part1=="0" and part2 == "2"){
          digitalWrite(elementPin,HIGH);
          stepper.moveTo(motorpos[part1.toInt()][part2.toInt()][0]);
          stepper.runToPosition();
          while (stepper.distanceToGo() != 0) {} // 等待步进电机完全移动到位
          digitalWrite(elementPin,HIGH);
          servo_b.write(motorpos[part1.toInt()][part2.toInt()][1]);
          servo_d.write(110);
          delay(500);
          servo_d.write(motorpos[part1.toInt()][part2.toInt()][3]);
          digitalWrite(elementPin,HIGH);
          servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]/2);
          delay(500);
          digitalWrite(elementPin,HIGH);
          servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]);
          delay(2500);
          status = 0; //turn off the electromagnet
          digitalWrite(elementPin, LOW);
          delay(1000);
          Serial.println("Putdown!");
        }
        else{
          digitalWrite(elementPin,HIGH);
          stepper.moveTo(motorpos[part1.toInt()][part2.toInt()][0]);
          stepper.runToPosition();
          while (stepper.distanceToGo() != 0) {} // 等待步进电机完全移动到位
          digitalWrite(elementPin,HIGH);
          servo_b.write(motorpos[part1.toInt()][part2.toInt()][1]);
          servo_d.write(motorpos[part1.toInt()][part2.toInt()][3]);
          digitalWrite(elementPin,HIGH);
          servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]/2);
          delay(500);
          digitalWrite(elementPin,HIGH);
          servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]);
          delay(2500);
          status = 0; //turn off the electromagnet
          digitalWrite(elementPin, LOW);
          delay(1000);
          Serial.println("Putdown!");
        }
        
      }     
      else if(index1 != -1) {
            
        String part1 = pycmd1.substring(1, index1); // 提取逗号前的部分
        String part2 = pycmd1.substring(index1 + 1); // 提取逗号后的部分
    
        stepper.moveTo(stonepos[part1.toInt()][part2.toInt()][0]);
        stepper.runToPosition();
        while (stepper.distanceToGo() != 0) {} // 等待步进电机完全移动到位
        status = 1;//turn on the electromagent
        servo_b.write(stonepos[part1.toInt()][part2.toInt()][1]);
        servo_d.write(stonepos[part1.toInt()][part2.toInt()][3]);
        servo_c.write(stonepos[part1.toInt()][part2.toInt()][2]);
        digitalWrite(elementPin,HIGH);
        delay(1500);
        digitalWrite(elementPin,HIGH);
        servo_c.write(0);
        servo_b.write(30);
        servo_d.write(90);
        delay(500);
        Serial.println("Pickup!");
      }     
      else{
      reset();
      }
  }  

  //---------------------------------------------------
  if (indexabn != -1){
    if (index != -1) { // 如果找到逗号
      String part1 = pycmd1.substring(1, index); // 提取逗号前的部分
      String part2 = pycmd1.substring(index + 1); // 提取逗号后的部分
      servo_c.write(0);
      servo_b.write(20);
      servo_d.write(90);
      delay(1000);
      stepper.moveTo(motorpos[part1.toInt()][part2.toInt()][0]);
      stepper.runToPosition();
      while (stepper.distanceToGo() != 0) {} // 等待步进电机完全移动到位
      status = 1;//turn on the electromagent
      servo_b.write(motorpos[part1.toInt()][part2.toInt()][1]);
      servo_d.write(motorpos[part1.toInt()][part2.toInt()][3]);
      servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]/2);
      delay(300);
      servo_c.write(motorpos[part1.toInt()][part2.toInt()][2]);
      delay(1500);
      digitalWrite(elementPin,HIGH);
      delay(1000);
      servo_c.write(0);
      servo_b.write(20);
      servo_d.write(90);
      delay(1000);

      Serial.println("Pickup!");
    }
    else if(index1 != -1) {
      String part1 = pycmd1.substring(1, index1); // 提取逗号前的部分
      String part2 = pycmd1.substring(index1 + 1); // 提取逗号后的部分
      digitalWrite(elementPin,HIGH);
      stepper.moveTo(stonepos[part1.toInt()][part2.toInt()][0]);
      stepper.runToPosition();
      while (stepper.distanceToGo() != 0) {} // 等待步进电机完全移动到位
      digitalWrite(elementPin,HIGH);
      servo_b.write(stonepos[part1.toInt()][part2.toInt()][1]);
      delay(500);
      servo_d.write(stonepos[part1.toInt()][part2.toInt()][3]);
      servo_c.write(stonepos[part1.toInt()][part2.toInt()][2]/2);
      delay(400);
      servo_c.write(stonepos[part1.toInt()][part2.toInt()][2]);
      digitalWrite(elementPin,HIGH);
      delay(2500);
      status = 0; //turn off the electromagnet
      digitalWrite(elementPin,LOW);
      delay(1000);
      
      Serial.println("Putdown!");
    }
    else{
      reset();
    }
  }
}
//----------------------
void reset(){
  digitalWrite(elementPin,LOW);
  servo_c.write(0);
  delay(500);
  servo_b.write(0);
  servo_d.write(90);
  stepper.moveTo(0);
  stepper.runToPosition();
  Serial.println("reset!");
}