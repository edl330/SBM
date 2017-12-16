// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

class KinectTracker {
  int maxDepth; 
  // Depth data
  int[] depth;
  PImage display;
  PGraphics pg;


  KinectTracker() {
    maxDepth=960;
    kinect.initDepth();
    display = createImage(kinect.width, kinect.height, RGB);
    pg = createGraphics(640, 480);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;
    display.loadPixels();
    
    for (int y=0;y<kinect.height;y++){
     for (int x=0;x<kinect.width;x++){
       int loc = x+y*kinect.width;
       PVector currentPixel= new PVector(x,y);
       PVector dist = PVector.sub(currentPixel, center); 
       if (depth[loc] <= maxDepth && dist.mag()<bDiameter/2) {
        display.pixels[loc] = color(255);
      } else {
        display.pixels[loc] = color(0);
      }
     }
      
    }
    //for (int i=0; i < depth.length; i++) {
    //  //if (depth[i] <= maxDepth) {
    //  //  display.pixels[i] = color(255);
    //  //} else {
    //  //  display.pixels[i] = color(0);
    //  //}
    //}
    // Draw the thresholded image
    display.updatePixels();

    pg.beginDraw(); //start drawing into our PGraphics buffer
    pg.image(display, 0, 0);
    pg.fill(0);
    pg.ellipse(center.x, center.y, sDiameter, sDiameter);
    pg.endDraw();//stop drawing into our buffer

    PImage img =pg.get();
    opencv.loadImage(img);
  }

  void display() {
    // Draw the image
    image(pg, 0, 0);
    noFill();
    stroke(255, 0, 0);
    strokeWeight(3);
    for (int i=0; i<8; i++) {
      sectionsActive[i]=false;
    }
    for (Contour contour : opencv.findContours()) {
      contour.draw();
      Rectangle r = contour.getBoundingBox();
      for (int i=0; i<8; i++) {
        PVector blobCenter = new PVector((float)r.getCenterX(), (float)r.getCenterY());
        PVector lineBetween = PVector.sub(blobCenter, center);
        //get the angle of that vector
        float angle = lineBetween.heading();
        //get the distance of the mouse from the center
        float distance = lineBetween.mag();
        if (angle>sections[i] && angle<sections[i+1] && distance>bDiameter/4 && distance<bDiameter/2) {
          sectionsActive[i]=true;
        }
      }

      //if (//(contour.area() > 0.9 * src.width * src.height) ||
      //  (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      //  continue;

      stroke(255, 0, 0);
      fill(255, 0, 0, 150);
      strokeWeight(2);
      rect(r.x, r.y, r.width, r.height);
      fill(0, 255, 0, 150);
      ellipse((float)r.getCenterX(), (float)r.getCenterY(), 15, 15);
      noFill();
    }
   
  }
}