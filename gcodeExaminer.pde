// gcodeExaminer by Whosawhatsis
// based on gcode3b by peter jansen
// g-code visualizer for toolpaths expored from skeinforge for the reprap/makerbot.  
// please feel free (and encouraged) to modify.  if you do, please post your modifications
// to the reprap forum post: 
// http://dev.forums.reprap.org/read.php?12,27884
// best of luck, and happy tinkering!



import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;


MouseWheelEventDemo wheel;


import processing.opengl.*;
import processing.video.*;

MovieMaker mm;
int width = 640;
int height = 480;

float pi = 3.1415926;

float arrowSize = 5;
float depth = 400;
color boxFill;
int speed = 1;
boolean demo = true;

String[] inputfile;
Points[] allpoints;
int numpoints;
int maxpoints = 500000;
float cur_z = 0;
float max_z = 0;

int cur_index = 0;


float rotationX = 0;
float rotationY = 0;


float current_height = 0;
float current_rot_x = 0;

float max_f = 0;
float max_e = 0;

void setup() {
//  size(640, 360, P3D);
  size(640, 480, P3D);
//  size(width, height, OPENGL); hint(DISABLE_OPENGL_2X_SMOOTH);  
//  size(1280, 720, P3D);
  noStroke();
  colorMode(HSB, 255);
  PFont font;
  font = loadFont("Monospaced-12.vlw");
  hint(ENABLE_NATIVE_FONTS);
  textFont(font);
  
//  inputfile = loadStrings("horseshoe-clip_export.gcode");
//  inputfile = loadStrings("rocket_export.gcode");
  String filename = selectInput();
  println(filename);
  inputfile = loadStrings(filename);

  allpoints = new Points[maxpoints];
  wheel = new MouseWheelEventDemo();
  numpoints = 0;

  // Cycle through all lines
  float e = 0;
  for (int i=0; i<inputfile.length; i++) {
    String pieces[] = split(inputfile[i], ' ');  // deliminate data by spaces
    
    // Check for G1 code
    if (pieces.length > 2) {
      if (pieces[0].equals("G1")) {
        // Add new point
        
        if (numpoints < maxpoints) {
          allpoints[numpoints] = new Points(pieces);
          allpoints[numpoints].l = i;
          
          // find maximum Z point for animation
          if (allpoints[numpoints].z > max_z) {
            max_z = allpoints[numpoints].z;
          }
          // find maximum F for colour 
          if (allpoints[numpoints].f > max_f) {
            max_f = allpoints[numpoints].f;
          }
          
          numpoints ++;
        }
        
        
        
      }
    }
  }  
  
  // Start Recording Animation
//  mm = new MovieMaker(this, width, height, "drawing1.mov");

//  mm = new MovieMaker(this, width, height, "test6_640_480.mov", 15, MovieMaker.H263, MovieMaker.LOSSLESS);
//  mm = new MovieMaker(this, width, height, "test6_640_480.mov", 15, MovieMaker.JPEG, MovieMaker.LOSSLESS);

}

public class MouseWheelEventDemo implements MouseWheelListener {
 public MouseWheelEventDemo() {
   addMouseWheelListener(this);
 }
 public void mouseWheelMoved(MouseWheelEvent e) {
   demo = false;
   depth += e.getWheelRotation() * 5;
 }
}

void draw() {
  background(255);
  float s = 20.0;
  float initial_speed = 0.002;
  float overhead_height = 0.0;
  for(int i = allpoints[cur_index].l; i < inputfile.length && i < allpoints[cur_index].l + 40; i++) {
    if (i == allpoints[cur_index].l) fill(0, 0, 0, 255);
    else fill(0, 0, 0, 64);
    text(inputfile[i], 2, 2 + 12 * (i - allpoints[cur_index].l), 2000, 476);
  }
  

//  println(allpoints[cur_index].z);
  if(mousePressed){
    demo = false;
    rotationY -= (mouseX-pmouseX) * 0.01;
    rotationX -= (mouseY-pmouseY) * 0.01;
  } else if (demo) {
    rotationY += .02;
    rotationX -= (rotationX - pi / 2) / 100;
  }
  translate(width/2, height/2 + allpoints[cur_index].z * sin(rotationX) * 10,  - depth - (allpoints[cur_index].z * 20) - (allpoints[cur_index].z) * (cos(rotationX) * 10));
  
  rotateX(rotationX);  
  rotateZ(rotationY);
  
  if (false)
  // Center and spin grid
  if ((frameCount * initial_speed) < pi/2) {
    translate(width/2, height/2, -depth);
    rotateX(frameCount * initial_speed);
    rotateZ(-frameCount * initial_speed);

  } else {
    if (current_height < (s * allpoints[cur_index].z) + overhead_height) {
      current_height += 0.85;
    }
    if ((frameCount * initial_speed) > pi) {
      if (current_rot_x > -pi/12) {
        current_rot_x -= 0.001;
      }
    }
    translate(width/2, height/2 + (current_height) , -depth );
    rotateX(pi/2 + current_rot_x);    
    rotateZ(-frameCount * initial_speed);

//    rotateZ(0);    
  }


  scale(1, -1, 1); // Right-handed coordinate system, please. Thank you.


  // Build grid using multiple translations 
  for (int i=0; i < numpoints-1; i++){
    
//    boxFill = color(abs(i), abs(j), abs(k), 50 );

//    boxFill = color(0, 0, 100 + round(i/numpoints), 50 );
    // Colour
    float alpha_value = 255;
//    if (i == 1) println(alpha_value);
    
    if(i > cur_index) {
      if (allpoints[i].z == allpoints[cur_index].z) alpha_value = 20;
      else alpha_value = 1;
    } else if (i < cur_index) {
      alpha_value = 255 - (cur_index - i) * 255 / (60 + speed);
      if (alpha_value < 20) alpha_value = 20;
      if (allpoints[i].z == allpoints[cur_index].z && alpha_value < 70) alpha_value = 50;
    }
    

    /*
    if ( false &&(i + speed * 2 + 30) < cur_index || alpha_value < 20) {
      if (cur_index > i) {
        // current layer is below cur_z, so the alpha can be less transparent 
        alpha_value = 20;
      } else {
        alpha_value = 1;              
      }

    }   
    
    if (alpha_value > 128) {
     // alpha_value = 2;
    }*/
    
    if (allpoints[i].z == allpoints[cur_index].z) boxFill = color(255, 255, 100 + 100*round(allpoints[i].f / max_f), alpha_value );
    else boxFill = color(150, 100, 100 + 100*round(allpoints[i].f / max_f), alpha_value);
            
        float basex0 = s * allpoints[i].x;
        float basey0 = s * allpoints[i].y;
        float basez0 = s * allpoints[i].z;
        float basex1 = s * allpoints[i+1].x;
        float basey1 = s * allpoints[i+1].y;
        float basez1 = s * allpoints[i+1].z;
       
       
       
//        pushMatrix();   
//        translate(s * allpoints[i].x + (a*difx), s * allpoints[i].y + (a*dify), s * allpoints[i].z + (a*difz));
        fill(boxFill);
        float en = 5.0f;
        // draw a triangle
        beginShape(TRIANGLE_STRIP);
        vertex(basex0, basey0, basez0);
        vertex(basex1, basey1, basez1);
        vertex(basex0 + en, basey0, basez0);
        vertex(basex1 + en, basey1, basez1);
        vertex(basex0 + en, basey0, basez0 + en);
        vertex(basex1 + en, basey1, basez1 + en);
        vertex(basex0, basey0, basez0 + en);
        vertex(basex1, basey1, basez1 + en);

        endShape();
        
        //box(boxSize, boxSize, boxSize);
//        popMatrix();
    

  }

  if (speed != 0) {
    // Alpha animation update
    cur_index += speed;
    if (cur_index >= numpoints - speed + 1) {
      cur_z = 0;
      cur_index = numpoints - 1;
  //    cur_index = numpoints - speed + 1;
    } else speed++;
  }

  // Add window's pixels to movie
//  mm.addFrame();


/*
  // Build grid using multiple translations 
  for (float i =- depth/2+margin; i <= depth/2-margin; i += boxSize){
    pushMatrix();
    for (float j =- height+margin; j <= height-margin; j += boxSize){
      pushMatrix();
      for (float k =- width+margin; k <= width-margin; k += boxSize){
        // Base fill color on counter values, abs function 
        // ensures values stay within legal range
        boxFill = color(abs(i), abs(j), abs(k), 50 );
        pushMatrix();
        translate(k, j, i);
        fill(boxFill);
        
        // draw a triangle
        beginShape(TRIANGLES);
        vertex(0, 0, 0);
        vertex(boxSize, 0, 0);
        vertex(boxSize/2, boxSize, 0);
        endShape();
        
        //box(boxSize, boxSize, boxSize);
        popMatrix();
      }
      popMatrix();
    }
    popMatrix();
  }
  */
}


void keyPressed() {
  print(cur_index);
  print(' ');
  if (keyCode == RIGHT) {
    speed = 0;
    ++cur_index;
  } else if (keyCode == LEFT) {
    speed = 0;
    --cur_index;
  } else if (keyCode == UP) {
    speed = 0;
    ++cur_index;
    while(cur_index < numpoints - 1 && allpoints[cur_index].z == allpoints[++cur_index].z);
    --cur_index;
  } else if (keyCode == DOWN) {
    speed = 0;
    --cur_index;
    while(cur_index > 0 && allpoints[cur_index].z == allpoints[--cur_index].z);
    //++cur_index;
  } else if (key == ' ') {
    // Finish the movie if space bar is pressed
    mm.finish();
    // Quit running the sketch once the file is written
    exit();
  }
  if (cur_index < 1) cur_index = 1;
  else if (cur_index >= numpoints) cur_index = numpoints - 1;
  println(cur_index);
}


class Points {
  float x;
  float y;
  float z;
  float f;
  int l;
  
  public Points(String[] pieces) {
    x = float(pieces[1].substring(1));
    y = float(pieces[2].substring(1));
    z = float(pieces[3].substring(1));
    f = float(pieces[4].substring(1));
  }
}
