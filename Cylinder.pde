class Cylinder
{
  
  float cylinderHeight = 50;
  int cylinderResolution = 40;
  PShape openCylinder = new PShape();
  PShape triangle = new PShape();
  PShape triangle2 = new PShape();
   PShape fullCylinder = new PShape();
   PVector location;

  Cylinder() {
    
    float angle;
    float[] x = new float[cylinderResolution+1];
    float[] y = new float[cylinderResolution+1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = cos(angle) * cylinderBaseSize;
      y[i] = sin(angle) * cylinderBaseSize;
    }

    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    openCylinder.fill(255,0,0);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.endShape();

    triangle = createShape();
    triangle.beginShape(TRIANGLE_FAN);
    // draw the top and bottom of the cylinder
    triangle.fill(255,0,0);
    triangle.vertex(0, 0, cylinderHeight);
    for (int i = 0; i < x.length; i++) {
      triangle.vertex( x[i], y[i], cylinderHeight);
    }
    triangle.endShape();
    triangle2 = createShape();
    triangle2.beginShape(TRIANGLE_FAN);
    triangle2.fill(255,0,0);
    triangle2.vertex(0, 0, 0);
    for (int i = 0; i < x.length; i++) {
      triangle2.vertex( x[i], y[i], 0);
    }
    triangle2.endShape();
    
  


    fullCylinder = createShape(GROUP);
    fullCylinder.addChild(openCylinder);
    fullCylinder.addChild(triangle);
    fullCylinder.addChild(triangle2);
  }  
  
  
  
}