class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce ,friction;
  PVector normal ;
  float gravityConstant=  0.09, frictionMagnitude;
  float cylinderBaseSize = 50;
  float elasticity = 0.85;  
  
  float totalScore;
  float lastScore;
  
  boolean collision = false;                                              
  
  Mover() {      //whenever we enter the Mover class we do a change of coordinates, so here the z coordinate represents
                 //the y coordinate of the "Game" and the y coordinate here will always be 0 since we are working on a 2 dimensional space
    location = new PVector(0, 0,0);
    velocity = new PVector(0, 0,0);
    gravityForce= new PVector(0, 0,0);
    normal = new PVector(0,0,0);
    float normalForce = 1;
    float mu = 0.01;
    frictionMagnitude = normalForce * mu;
    
    totalScore=0;
    lastScore=0;

  }
  
  void update(float rotX, float rotZ) {
    gravityForce.x = sin(rotZ) * gravityConstant;
    gravityForce.z = sin(rotX) * gravityConstant;
    friction = velocity.copy();                                            
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    
    if(!collision){                                                       
      velocity.add(gravityForce);
      velocity.add(friction);
    }
    location.add(velocity);
    
  }
  void display()
  {
     gameSurface.translate(location.x, location.y-(boardThickness/2+sphereSize), -location.z);
     gameSurface.fill(130,150,255);
     gameSurface.sphere(sphereSize);

  }
  
  void checkEdges() {
 
    if ((location.x > boardSize/2) || (location.x < -boardSize/2)) {
      velocity.x = velocity.x * -elasticity;                                
      location.x =Math.signum(location.x)*boardSize/2;
      totalScore-=velocity.mag();
      lastScore=-velocity.mag();
      
    }
    if ((location.z > boardSize/2) || (location.z < -boardSize/2)) {
      velocity.z = velocity.z * -elasticity;                                
       location.z =Math.signum(location.z)*boardSize/2;
        totalScore-=velocity.mag();
        lastScore=-velocity.mag();
    }
  }
  
  void checkCylinderCollision() {
    collision = false;                                                        
    for (int i = 0; i < cList.size(); ++i) {
      
      PVector cylocation = new PVector (cList.get(i).x, 0, -cList.get(i).y);
      normal = PVector.sub(cylocation, location).normalize();  

      float direction = velocity.dot(normal);                                  
      float distance = cylocation.dist(location);                              
      if (direction > 0 && distance < (cylinderBaseSize+sphereSize)){          
          collision = true;                                                    
          velocity = velocity.sub(normal.mult((2-1+elasticity)*(direction)));  

     totalScore+=velocity.mag();
     lastScore=velocity.mag();
      }
     
    }

  }
  
}