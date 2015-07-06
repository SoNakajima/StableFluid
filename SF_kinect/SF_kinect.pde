import processing.opengl.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.contacts.*;
import controlP5.*;
import SimpleOpenNI.*;


ControlP5 cp5;
Box2DProcessing box2d;
Sail sail;
BezierCurve b0, b1;
Bezier10 b10;
SimpleOpenNI kinect;

int WIDTH, HEIGHT;
int kyori;

int count = 0;

PVector[] bezierP = new PVector[11];

float trim;

int N=120;
int size = (N+2)*(N*2);
float  dt, diff, visc, force, source;
int dvel;

float adj;
float shift;

float[] u = new float[size];
float[] v = new float[size];
float[] u_prev = new float[size];
float[] v_prev = new float[size];
float[] dens = new float[size];
float[] dens_prev = new float[size];

boolean[] object = new boolean[size];


boolean[] mouse_down = new boolean[3];
int omx, omy, mx, my;

boolean blow;
boolean drawS;
boolean randomBlow;

float[] powX = new float[size];
float[] powY = new float[size];

/////////////
int NUM = 50;
float Ks; //banejousu
float Kd; //dumping
float edt;
float l;  // baneno sizenchou
float m; //situryou
float g;
//////////////


void clear_data() {
  for (int i=0; i<size; i++) {
    u[i] = v[i] = u_prev[i] = v_prev[i] = dens[i] = dens_prev[i] = 0.0f;
    object[i] = false;
    powX[i] = powY[i] = 0.0f;
  }
}

void pre_display() {
  noStroke();
  fill(50);
  rect(0, 0, width, height);
}

void draw_velocity() {
  float x, y, h, s;

  h = 1.0f/ (float)N;


  beginShape(LINES);
  for (int i=0; i<=N; i++) {
    x = (i-0.5f)*h;
    for (int j=0; j<=N; j++) {
      y = (j-0.5f)*h;
      s = (u[IX(i, j)]*u[IX(i, j)]+v[IX(i, j)]*v[IX(i, j)]);
      s *= 500000;
      s  = log(s)*30;
      colorMode(HSB);
      stroke(s, 255, s+60);
      fill(s, 255, s+60);  
      vertex(x*width, y*height);
      vertex((x+u[IX(i, j)])*width, (y+v[IX(i, j)])*height);
    }
  }
  endShape();
}

void draw_density() {
  float x, y, h, d00, d01, d10, d11;

  h = 1.0f/ (float)N;

  colorMode(RGB, 255);
  beginShape(QUADS);
  for (int i=0; i<=N; i++) {
    x = (i-0.5f)*h;
    for (int j=0; j<=N; j++) {
      y = (j-0.5f)*h;

      d00 = dens[IX(i, j)];
      d01 = dens[IX(i, j+1)];
      d10 = dens[IX(i+1, j)];
      d11 = dens[IX(i+1, j+1)];

      d00 *= 255;
      d10 *= 255;
      d11 *= 255;
      d01 *= 255;


      stroke(d00, 0, 0);
      fill(d00, 0, 0); 
      vertex(x*width, y*height);
      stroke(d10, 0, 0);
      fill(d10, 0, 0); 
      vertex((x+h)*width, y*height);
      stroke(d11, 0, 0);
      fill(d11, 0, 0); 
      vertex((x+h)*width, (y+h)*height);
      stroke(d01, 0, 0);
      fill(d01, 0, 0); 
      vertex(x*width, (y+h)*height);
    }
  }
  endShape();
}

void get_from_UI(float[] d, float[] u, float[] v) {
  int i, j;
  for (i=0; i<size; i++) {
    u[i] = v[i] = d[i] = 0.0f;
    powX[i] = powY[i] = 0.0f;
  }



  ///////////////////////////////
  ////// blow/////////////
  //////////////////

  if (blow) {
    float ratio = (force*adj)/(sqrt((force*adj)*(force*adj)+(0.1*shift)*(0.1*shift)));

    for (i=1; i<2; i++) {
      for (j=1; j<=N; j++) {
        u[IX(i, j)] = force*adj*ratio;
        v[IX(i, j)] = 0.1*shift*ratio;
      }
    }
  }

  /*

   if ( !mouse_down[1]) { 
   return;
   }
   
   i = (int)((mx /(float)width )*N+1);
   j = (int)((my /(float)height)*N+1);
   
   if ( (i<2) || (i>N-2) || (j<2) || (j>N-2) ) { 
   return;
   }
   
   if (mouse_down[0] ) {
   u[IX(i, j)] = force * (mx-omx);
   v[IX(i, j)] = force * (my-omy);
   }
   
   if (mouse_down[2]) {
   d[IX(i, j)] = source;
   }
   
   omx = mx;
   omy = my;
   */
}

void keyPressed() {
  switch(key) {


  case 'c':
  case 'C':
    clear_data();
    break;

  case 'v':
  case 'V':
    if (dvel != 1) {
      dvel = 1;
    } else { 
      dvel = 0;
    }
    break;


  case 'b':
  case 'B':
    if (! blow) {
      blow = true;
    } else {
      blow = false;
    }
    break;

  case 's':
  case 'S':
    drawS = !drawS;
    break;

  case 'R':
  case 'r':
    randomBlow = !randomBlow;
    break;
  case ' ':
    float x = (float)mouseX;
    float y = (float)mouseY;
    rect(x-10, y-10, 20, 20);

    object[IX((int)(x/width *N), (int)(y/height *N))] = true;
    object[IX((int)(x/width*N)+1, (int)(y/height*N))] = true;
    object[IX((int)(x/width*N), (int)(y/height*N)+1)] = true;
    object[IX((int)(x/width*N)-1, (int)(y/height*N))] = true;
    object[IX((int)(x/width*N), (int)(y/height*N)-1)] = true;

    break;
  }
  if (key == CODED) {      
    if (keyCode == UP) {
    } else if (keyCode == DOWN) {
    } else if (keyCode == LEFT) {
    } else if ( keyCode == RIGHT) {
    }
  }
}

void mousePressed() {
  mouse_down[1] = true;
  omx = mx = mouseX;
  omy = my = mouseY;

  if (mouseButton == RIGHT) {
    mouse_down[2] = true;
  } else if (mouseButton == LEFT) {
    mouse_down[0] = true;
  }
}

void mouseReleased() {
  mouse_down[1] = false;
  mouse_down[0] = mouse_down[2] = false;
}


void idle_func() {
  get_from_UI( dens_prev, u_prev, v_prev);
  vel_step( N, u, v, u_prev, v_prev, visc, dt);
  dens_step( N, dens, dens_prev, u, v, diff, dt);


  display_func();
}


void display_func() {
  pre_display();

  if (dvel == 0) { 
    draw_density();
  } else if (dvel == 2) {
    draw_Speed();
  } else if (dvel == 1) {
    draw_velocity();
  }
}


void drawSquare(float x, float y, float side)
{
  rect(x*width, y*height, side*width, side*height);
}

void drawObjects()
{
  stroke(0);
  fill(123);

  float x, y, h;
  h = 1.0f / (float)N;
  for (int i = 0; i < N+2; i++)
  {
    x = (i-0.5f)*h;
    for (int j = 0; j < N+2; j++)
    {
      y = (j-0.5f)*h;
      if (object[IX(i, j)])
      {
        drawSquare(x, y, h);
      }
    }
  }
}



void setup() {
  WIDTH = 640;
  HEIGHT = 480;
  kyori = 500;
  frameRate(30);
  size(WIDTH, HEIGHT, P2D);
  frameRate(30);
  colorMode(RGB, 255);
  cursor(CROSS);

  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();

  PFont font = loadFont("Helvetica-Bold-48.vlw");
  textFont(font);

  for (int i=0; i<11; i++) {
    bezierP[i] = new PVector();
  }

  b10 = new Bezier10(bezierP);

  ////////////////////// BOX2D ///////////////////////

  box2d = new Box2DProcessing(this);
  Vec2 g = new Vec2(0, 0);
  box2d.createWorld(g);

  sail = new Sail(600, 10);
  ////////////////////////////////////////////////////

  b0 = new BezierCurve(150, 150, 300, 130, 400, 150, 680, 250);
  b1 = new BezierCurve(150, 120, 300, 100, 400, 120, 680, 300);

  dvel = 1;

  blow = true;
  drawS = false;
  randomBlow = false;

  mouse_down[0]=mouse_down[1]=mouse_down[2]=false;

  for (int i=0; i<size; i++) {
    u[i]=v[i]=u_prev[i]=v_prev[i]=dens[i]=dens_prev[i]=0.0f;
    powX[i] = powY[i] = 0.0f;
  }

  /////////////////////////////////////
  adj = 0.15;
  dt = 0.4f;
  diff = 0.00f;
  visc = 0.0001f;
  force = 3.0f;
  source = 80.0f;
  ///////////////////////////////////// 
  //////////////////////////////////////

  trim = 0;

  cp5 = new ControlP5(this);
  cp5.addSlider("dt", 0.00000001, 1.0, 0.4, 30, 400, 100, 15);
  cp5.addSlider("adj", 0.00000001, 0.25, 0.15, 30, 420, 100, 15);
  cp5.addSlider("shift", -1, 1, 0, 30, 440, 100, 15);
}
void draw() {

  mx = mouseX;
  my = mouseY;


  idle_func();



//  drawObjects(); 

  //  box2d.step();
  //  sail.setObject();

  /* kesitayo
   sail.move();
   
   
   for (int i=0; i<11; i++) {
   bezierP[i].x = sail.POS[i].x;
   bezierP[i].y = sail.POS[i].y;
   }
   */



  kinect.update();
  int[] depthMap = kinect.depthMap();

  for (int i=0; i<size; i++) {
    object[i] = false;
  }
  int xmin = 0;
  int xmax = 0;
  boolean haji = false;
  int y = HEIGHT/2;
  for (int i=100; i<WIDTH-100; i+=5) {
    int x = i;
    
    int index = x + y*WIDTH;
    int distance = depthMap[index];
    //    object[IX(50,50)] = true;

    //    println(distance);   
    if (distance-kyori > 20 && distance - kyori < 460) {
      if (haji==false) {
        xmin = x;
        haji = true;
      }
      xmax = x;
//            object[IX((int)((float)x/width *N), (int)((float)(HEIGHT-(distance - kyori))/height *N))] = true;
//            object[IX((int)((float)x/width*N), (int)((float)(HEIGHT-(distance - kyori))/height*N)-1)] = true;
//            object[IX((int)((float)x/width*N)-1, (int)((float)(HEIGHT-(distance - kyori))/height*N)-1)] = true;
//            object[IX((int)((float)x/width*N)+1, (int)((float)(HEIGHT-(distance - kyori))/height*N)-1)] = true;
//            object[IX((int)((float)x/width*N), (int)((float)(HEIGHT-(distance - kyori))/height*N)+1)] = true;
//            object[IX((int)((float)x/width*N)-1, (int)((float)(HEIGHT-(distance - kyori))/height*N)+1)] = true;
//            object[IX((int)((float)x/width*N)+1, (int)((float)(HEIGHT-(distance - kyori))/height*N)+1)] = true;      
//            object[IX((int)((float)x/width*N)-1, (int)((float)(HEIGHT-(distance - kyori))/height*N))] = true;
//            object[IX((int)((float)x/width*N)+1, (int)((float)(HEIGHT-(distance - kyori))/height*N))] = true;
    }
  }


if (depthMap[WIDTH/2 + y*WIDTH]-kyori > 20 && depthMap[WIDTH/2 + y*WIDTH] - kyori < 460) {
  for (int j=0; j<11; j++) {
    bezierP[j].x = xmin + ((xmax-xmin)/10)*j;
    bezierP[j].y = HEIGHT-depthMap[xmin + ((xmax-xmin)/10)*j + y*WIDTH]+kyori;
  }
  b10.draw(bezierP);
}

  strokeWeight(0.5);
  colorMode(RGB);

  fill(255);
  textSize(15);
  text("Press R to random mode", 30, 473);
  //  fill(0, 255, 0);
  //  textSize(15);
  //  text("force *"+adj, 20, 20);
  //  text("dt = "+dt, 20, 40);
  //  text("shift"+shift, 20, 60);

  textSize(35);
  fill(255);
  if (shift>0) text("HEADER", 248, 45);
  if (shift<0) text("LIFT", 282, 45);

  if (drawS) drawSprings();

  //  Trim();

  if (randomBlow) {
    randomBlow();
  }
  count += 1;
}





void drawSprings() {
  sail.display();
  fill(0, 255, 0);
  stroke(255);
  for (int i=0; i<11; i++) {
    ellipse(sail.defPos[i].x, sail.defPos[i].y, 5, 5);
    line(sail.defPos[i].x, sail.defPos[i].y, bezierP[i].x, bezierP[i].y);
  }
}

void Trim() {
  int x, y, w, h;

  x = 520;
  y = 370;
  w = h = 80;

  if ((mouseX>x)&&(mouseX<x+w)&&(mouseY>y)&&(mouseY<y+h)&&(mousePressed)) {
    trim += 5;
    fill(200);
    ellipse(x+40, y+40, 80, 80);
  } else {
    if (trim<100) trim -= 1;
    else if (trim<200) trim -= 6;
    else if (trim<300) trim -= 15;
    else trim -= 25;

    if (trim < 0) trim = 0;
    fill(230);
    ellipse(x+40, y+40, 80, 80);
  }

  fill(0, 200, 255);
  textSize(20);
  text("TRIM", x+15, y+48);


  println(trim);
}

void randomBlow() {
  if (count % 90 == 0) {
    adj += random(-0.05, 0.05);
    shift += random(-0.1, 0.1);
    if (adj<0.01) adj = 0.01;
  }
}

