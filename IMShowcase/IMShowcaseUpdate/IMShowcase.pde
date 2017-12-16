import themidibus.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import gab.opencv.*;
import java.awt.Rectangle;
import oscP5.*;
import netP5.*;

KinectTracker tracker;
Kinect kinect;
MidiBus myBus; 
OpenCV opencv;
OscP5 oscP5;
NetAddress myRemoteLocation;

float bDiameter = 281;
float sDiameter = 240;
//int time;
//int wait = 500;
boolean keyB = false;
boolean keyS = false;
boolean moveCenter = false;
boolean adjustThreshold = false;
float[] sections = new float[9];
boolean[] sectionsActive = new boolean[8];
boolean[] prevSectionsActive = new boolean [8];
int[] noteValues = {60, 63, 67, 68, 70, 72, 74, 75};
float volume = 0;
float volumeDestination = 0;
PVector center;

void setup() {
  size(640, 480);

  kinect = new Kinect(this);
  tracker = new KinectTracker();
  opencv = new OpenCV(this, 640, 480);
  //time = millis();

  float section = TWO_PI/8;
  float rotateAngle=-PI;
  for (int i=0; i<9; i++) {
    sections[i]=rotateAngle;
    rotateAngle+=section;
    if (i<8) {
      sectionsActive[i]=false;
    }
  }

  MidiBus.list();
  myBus = new MidiBus(this, -1, "sforzando");
  center = new PVector(270, 250);

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 1234);
}

void draw() {
  background(255);
  noFill();
  //get vectors of our mouse and center locations
  //PVector mouse = new PVector(mouseX, mouseY);

  tracker.track();
  tracker.display();


  if (keyB == true) {
    bDiameter = mouseX;
    println(bDiameter);
  }

  if (keyS == true) {
    sDiameter = mouseX;
    println(sDiameter);
  }


  if (moveCenter) {
    center.x=mouseX;
    center.y=mouseY;
    println(center);
  }
  strokeWeight(1);
  stroke(255);
  //draw circles at those locations
  ellipse(center.x, center.y, bDiameter, bDiameter);
  ellipse(center.x, center.y, sDiameter, sDiameter);




  //move coordinate system to center 
  //so we can rotate a line based on our angle

  fill(0);
  //get a vector pointing between the mouse and the center
  //PVector lineBetween = PVector.sub(mouse, center);
  ////get the angle of that vector
  //float angle = lineBetween.heading();
  ////get the distance of the mouse from the center
  //float distance = lineBetween.mag();
  float section = TWO_PI/8;
  float rotateAngle=0;
  translate(center.x, center.y);
  for (int i=0; i<8; i++) {
    pushMatrix();
    rotate(rotateAngle);
    line(0, 0, bDiameter/2, 0);
    popMatrix();
    rotateAngle+=section;
  }
  //println(sectionsActive);
  for (int i=0; i<8; i++) {
    if (sectionsActive[i]==true && prevSectionsActive[i]==false) {
      myBus.sendNoteOn(1, noteValues[i], 100);
    } else if (sectionsActive[i] == false) {
      myBus.sendNoteOff(1, noteValues[i], 100);
    }
  }

  // send to Isadora 
  for (int i=0; i<8; i++) {
    String isadoraAddress = "/isadora/";
    isadoraAddress+=String.valueOf(i+1);
    OscMessage myMessage = new OscMessage(isadoraAddress);
    if (sectionsActive[i]==true) {
      myMessage.add(1);
    } else 
    myMessage.add(0);
    oscP5.send(myMessage, myRemoteLocation);
  }

  arrayCopy(sectionsActive, prevSectionsActive);

  //if (millis() - time >= wait) {
  //  myBus.sendNoteOn(channel, pitch, velocity);
  //  time = millis();
  //myBus.sendNoteOff(channel, pitch, velocity);
}

void keyPressed() {
  if (key == 'b')
    keyB = !keyB;
  if (key == 's')
    keyS = !keyS;
  if (key == 'm')
    moveCenter = !moveCenter;
  if (key == 't') {
    tracker.maxDepth+=10;
    println(tracker.maxDepth);
  }
  if (key == 'r') {
    tracker.maxDepth-=10;
    println(tracker.maxDepth);
  }
  if (key == 'e') {
    tracker.maxDepth-=100;
    println(tracker.maxDepth);
  }
}