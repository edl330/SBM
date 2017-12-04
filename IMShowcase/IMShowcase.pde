import themidibus.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

KinectTracker tracker;
Kinect kinect;
MidiBus myBus; 

int minDepth =  800;
int maxDepth = 900;

float[] sections = new float[9];
float volume = 0;
float volumeDestination = 0;

void setup() {
  size(640, 480);
  float section = TWO_PI/8;
  float rotateAngle=-PI;

  kinect = new Kinect(this);
  tracker = new KinectTracker();

  for (int i=0; i<9; i++) {
    sections[i]=rotateAngle;
    rotateAngle+=section;
  }

  MidiBus.list();
  myBus = new MidiBus(this, -1, "Bus 1");
}


void draw() {
  background(255);
  noFill();
  //get vectors of our mouse and center locations
  //PVector mouse = new PVector(mouseX, mouseY);
  PVector center = new PVector(width/2, height/2);

  tracker.track();
  tracker.display();

  PVector v1 = tracker.getPos();
  PVector v2 = tracker.getLerpedPos();

  //draw circles at those locations
  ellipse(center.x, center.y, 300, 300);
  ellipse(center.x, center.y, 100, 100);
  ellipse(v2.x, v2.y, 30, 30);

  //get a vector pointing between the mouse and the center
  PVector lineBetween = PVector.sub(v2, center);
  //get the angle of that vector
  float angle = lineBetween.heading();
  println(angle);
  //get the distance of the mouse from the center
  //float distance = lineBetween.mag();

  //move coordinate system to center 
  //so we can rotate a line based on our angle
  translate(center.x, center.y);

  //example just showing how to convert from 360 degrees to radians 
  float myAngle = radians(30);

  //built in variables
  //println(TWO_PI + " " + PI + " " + HALF_PI);

  //actually rotate our line using our angle
  //rotate(angle);
  //line(0, 0, 150, 0);
  
  int t = tracker.getThreshold();
  fill(0);

  float section = TWO_PI/8;
  float rotateAngle=0;
  for (int i=0; i<8; i++) {
    pushMatrix();
    rotate(rotateAngle);
    line(0, 0, 150, 0);
    popMatrix();
    rotateAngle+=section;

    if (angle>sections[i] && angle<sections[i+1]) {
      println("in section "+ i);
    }
  }
  if (angle < (TWO_PI/8) && angle > 0) {
    int channel = 0;
    int pitch = 60;
    int velocity = (100);
    //if (frameCount%100==0)
    myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
  }
}