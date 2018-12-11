import gab.opencv.*;

PGraphics gameSurface;
PGraphics scoreboard;
PGraphics barChart;

Mover mover;
HScrollbar hs;

boolean MouseMode=false;//We decided to have two modes, either we move the board using the camera/video, or using the mouse. Using both at the same time doesn't really make sense.
boolean shiftPressed=false;
public static float boardSize=500;
public static float boardThickness=20;
public static float sphereSize=20;
public static float cylinderBaseSize = 50;

int time = 0;
int scoreMax=0;
int currentScore = 0;

public ArrayList<PVector> cList=new ArrayList<PVector>();

float depth =2000.0;
float speed = 100.0;
float rotX = 0.0; 
float rotZ = 0.0; 
float savedRotX=0;
float savedRotZ=0 ;
float initX, initY;
Cylinder cyl;

float[] scoreTable;

PImage image;
PImage sob;
PImage back;

imageprocessing imageP;

void settings() {
  size(1000, 1000, P3D);
}
void setup() {

  gameSurface=createGraphics(width, height-100, P3D);
  noStroke();
  mover = new Mover();
  cyl=new Cylinder();

  backgroundSurface = createGraphics(width, 150, P2D);
  topViewSurface = createGraphics(backgroundSurface.height - 10, backgroundSurface.height - 10, P2D);
  scoreSurface = createGraphics(120, backgroundSurface.height - 10, P2D);
  bottomRect = createGraphics(backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, backgroundSurface.height - 40, P2D);

  scoreMax = (int)(bottomRect.width/2);
  scoreTable = new float[scoreMax];

  hs = new HScrollbar(topViewSurface.width + scoreSurface.width +50, height - 40, backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, 20);

  imageP = new imageprocessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imageP);
}
void drawGame()
{
  //the only change that was made to draw so that it works with the camera, is here
  if (rotation!=null&& !shiftPressed&& !MouseMode) {
    rotX=rotation.x;
    rotZ=rotation.z;
    // Following the instructions : Rotating more than 180 degrees around the horizontal axes and more than 90 degrees around the vertical axis will yield the same object from the image processing perspective
   rotX = min(max(rotX, -PI),PI);
   rotZ = min(max(rotZ,-PI/2),PI/2);
  }
  gameSurface.beginDraw();
  gameSurface.pushMatrix();
  gameSurface.directionalLight(100, 100, 100, 0.1, 1, -0.7);
  gameSurface.ambientLight(102, 102, 102);
  gameSurface.background(190, 230, 244);
  gameSurface.translate(width/2, height/2, 0);
  gameSurface.rotateZ(rotZ);
  gameSurface.rotateX(rotX);

  gameSurface.fill(160, 230, 110);
  gameSurface.box(boardSize, boardThickness, boardSize);
  for (int i=0; i<cList.size(); i++)
  {
    gameSurface.pushMatrix();
    gameSurface.rotateX(PI/2);
    gameSurface.translate(cList.get(i).x, cList.get(i).y, boardThickness/2);
    gameSurface.shape(cyl.fullCylinder);
    gameSurface.popMatrix();
  }

  if (!shiftPressed) {
    mover.update(rotX, rotZ);      
    mover.checkCylinderCollision();
    mover.checkEdges();
  }
  mover.display();
  gameSurface.endDraw();
  gameSurface.popMatrix();
}

void draw() {

  drawGame();
  image(gameSurface, 0, 0);

  drawBackgroundSurface();
  drawScoreSurface();
  drawBarChartSurface();
  drawTopViewSurface();
  image(backgroundSurface, 0, height - backgroundSurface.height);
  image(topViewSurface, 5, height-backgroundSurface.height+5);
  image(scoreSurface, topViewSurface.width + 20, height - scoreSurface.height - 5);
  image(bottomRect, topViewSurface.width + scoreSurface.width +50, height - scoreSurface.height - 5);

  hs.update();
  hs.display();
}

void mouseDragged() {
  if (!shiftPressed&&mouseY<=height-200)
  {

    float nextRotX = rotX + (pmouseY - mouseY)/speed;
    if (nextRotX>=-PI/3 && nextRotX <=PI/3) {
      rotX =nextRotX;
    }
    float nextRotZ = rotZ + (mouseX - pmouseX)/speed;
    if (nextRotZ>= -PI/3 && nextRotZ<= PI/3) {
      rotZ = nextRotZ;
    }
  }
}

void mouseWheel(MouseEvent event) {

  speed=speed - Math.signum(event.getCount())*10;
  if (speed<70) speed=70;
  if (speed>800)speed=800;
}

void keyPressed() {
  if (key == CODED) {

    if (keyCode == SHIFT) {
      shiftPressed=true;
      savedRotX = rotX;
      savedRotZ = rotZ;
      rotX = -PI/2;
      rotZ = 0;
    }
  }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftPressed=false;
      rotX=savedRotX;
      rotZ=savedRotZ;
    }
  }
}
void mousePressed()
{

  if (shiftPressed&&insideBounds(mouseX-boardSize/2, mouseY-boardSize/2)) {
    cList.add(new PVector(-(width/2-mouseX), -(height/2-mouseY), 0));
  }
}

boolean insideBounds(float x, float y) {
  if ((x > (boardSize-cylinderBaseSize/2)) || x < cylinderBaseSize/2) {
    return false;
  } else {
    return (y <= (boardSize-cylinderBaseSize/2)) && (y >= cylinderBaseSize/2);
  }
}