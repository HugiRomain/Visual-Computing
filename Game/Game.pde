//define the background color and the dimension of the sphere and the plate
float bgColor = 240;
float plateLength = 400;
float plateHeight = 20;
float sphereRadius = 10;

//define the coordinate of the 4 side of the plate in adding-cylinders mode
float leftSide, rightSide, topSide, bottomSide;

float pWidth, pHeight;

//define the colors of the elements of the game
color plateColor = #16F217;
color sphereColor = #FC651F;
color cylinderColor = #1EACD6;

//define and initialize the speed, the angles and the rotation of the plate
float speed = 1;
float angleX = 0;
float angleZ = 0;
float rotateX = 0;
float rotateZ = 0;

//define the mover and the sphereLocation
Mover mover;
Cylinder cylinder;
PVector sphereLocation;

ArrayList<PVector> cylinders = new ArrayList<PVector>();

void settings() {
  size(1000, 600, P3D);
}
void setup() {
  noStroke();
  mover = new Mover();
  cylinder = new Cylinder();
  
  pWidth = width;
  pHeight = height;
}

void draw() {
  drawBasics();
  if(keyPressed && keyCode == SHIFT){
    drawViewMode();
    drawCylinders2D();
  }
  else{
    drawGame();
    drawSphere();
  }
}

void mouseDragged() 
{
  //test if the game is not in adding-cylinders mode
  if(!(keyPressed && keyCode == SHIFT)){
    angleX += speed * (pmouseY - mouseY);
    angleZ += speed * (mouseX - pmouseX);
    
    angleX = bounds(60, -60, angleX);
    angleZ = bounds(60, -60, angleZ);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  speed -= e*0.1;
  
  if(speed > 1.5)
  {
    speed = 1.5;
  }
  else if(speed < 0.2)
  {
    speed = 0.2;
  }
}

//bound the angle of the plate(X and Z axis)
float bounds(float upperBound, float lowerBound, float angle){
  if(angle > upperBound){
    return upperBound;
  }
  else if(angle < lowerBound){
    return lowerBound;
  } else {
    return angle;
  }
}

//draw the basics (light and background)
void drawBasics(){  
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(bgColor);
  fill(255);
  textSize(20);
  text("Speed : " + speed, 10, 30);
  text("Angle X : " + angleX + " --- Angle Z : " + angleZ, 10, 50);
  text("Press 'r' to reset the game", 10, 70);
}

//draw the plate
void drawGame(){
  fill(plateColor);
  translate(width/2, height/2, 0);
  rotateX = radians(angleX);
  rotateZ = radians(angleZ);
  rotateX(rotateX);
  rotateZ(rotateZ);
  box(plateLength, plateHeight, plateLength);
  
  drawCylinders3D();
}

//draw the sphere
void drawSphere(){
  mover.update();
  mover.checkEdges();
  mover.checkCylinderCollision(cylinders);
  mover.display();
}

//draw the rectangle and the ball of the adding-cylinders mode
void drawViewMode(){   
  
  //check if the window has been resized
  if(pWidth != width || pHeight != height){
     for (PVector cylinderVector: cylinders){
       cylinderVector.x = map(cylinderVector.x, leftSide, rightSide, (width-plateLength)/2, (width+plateLength)/2);
       cylinderVector.y = map(cylinderVector.y, topSide, bottomSide, (height-plateLength)/2, (height+plateLength)/2);
       pWidth = width;
       pHeight = height;
     }
  }
  
  //initialize the 4 side of the plate
  //(initialized here in case if the window is resized)
  leftSide = (width-plateLength)/2;
  rightSide = (width+plateLength)/2;
  topSide = (height-plateLength)/2;
  bottomSide = (height+plateLength)/2;
  
  fill(plateColor);
  pushMatrix();  
    //draw the rectangle at the center of the window
    translate(width/2, height/2,0);
    rect(-plateLength/2, -plateLength/2, plateLength, plateLength);
    
    //draw the ball according to the current position of the sphere
    fill(sphereColor);
    ellipse(sphereLocation.x,sphereLocation.z , 2*sphereRadius, 2*sphereRadius);
  popMatrix();
   
  //draw a circle with a radius equals to the cylinder base size around the pointer
  fill(cylinderColor);
  ellipse(mouseX, mouseY , 2*cylinder.getBaseSize(), 2*cylinder.getBaseSize());
}

//draw the cylinders in the adding-cylinders mode
void drawCylinders2D(){
  for(PVector cylinderVector : cylinders){
    cylinder.update(cylinderVector.x, cylinderVector.y);
  }
}

//draws the cylinders on the game
void drawCylinders3D(){
  for(PVector cylinderVector : cylinders){
    pushMatrix();
      translate(map(cylinderVector.x, leftSide, rightSide, -200, 200), -plateHeight/2, map(cylinderVector.y, topSide, bottomSide, -200, 200));
      rotateX(HALF_PI);
      cylinder.update();
    popMatrix();
  }
}

//create a cylinder if the user release the mouse's button
//(we use mouseReleased instead of mouseClicked because it works better if the user make long-click)
void mouseReleased(){
  //check if we are in view mode
  if(keyPressed && keyCode == SHIFT){
    //check if the mouse position is on he plate and if it's not on the ball's position
    if(check() && !overlap(sphereLocation, new PVector(map(mouseX, leftSide, rightSide, -200, 200), -plateHeight/2, map(mouseY, topSide, bottomSide, -200, 200)))){
      cylinders.add(new PVector(mouseX, mouseY));
    }
  }
}

void keyPressed(){
  if(key == 'R' || key == 'r'){
     cylinders = new ArrayList<PVector>();
     mover = new Mover();
     angleX = angleZ = 0;
     speed = 1;
  }
}

//check if the cylinder is on the plate and if he is not on another cylinder or on the ball
boolean check(){
  if(mouseX + cylinder.getBaseSize() <= rightSide && mouseX - cylinder.getBaseSize() >= leftSide
        && mouseY + cylinder.getBaseSize() <= bottomSide && mouseY - cylinder.getBaseSize() >= topSide){
    return true;
  }
  return false;
}

//check if the 2 parameters overlap
boolean overlap(PVector sphere, PVector cylinderVector){
  if(dist(sphere.x, sphere.y, sphere.z, cylinderVector.x, cylinderVector.y, cylinderVector.z) <= sphereRadius + cylinder.getBaseSize()){
    return true;
  }
  return false;
}

//defition of the Mover class, which is used to update the sphere location and to display it
class Mover {
  
  //physic contants
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  float gravityConstant = 0.2;
  
  PVector velocity;
  PVector gravityForce;
  PVector friction;
  PVector n;
  
  Mover() {
    sphereLocation = new PVector(0, -plateHeight, 0);
    velocity = new PVector();
    gravityForce = new PVector(0, 0, 0);
    friction = new PVector();
  }
  
  //update the sphere location
  void update() {     
    //get the gravity force
    gravityForce.x = sin(rotateZ) * gravityConstant;
    gravityForce.z = -sin(rotateX) * gravityConstant;
    
    velocity.add(gravityForce.add(friction));
  
    //calculate the friction force
    friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    
    sphereLocation.add(velocity);
  }
  
  //display the sphere
  void display() {
    fill(sphereColor);
    translate(sphereLocation.x, sphereLocation.y, sphereLocation.z);
    sphere(sphereRadius);
  }
  
  //check if the sphere hits a wall
  void checkEdges() {
    if(sphereLocation.x - sphereRadius < -plateLength/2){
      velocity.x = -velocity.x/2;
      sphereLocation.x = -plateLength/2+sphereRadius;
    } else if(sphereLocation.x + sphereRadius > plateLength/2){
      velocity.x = -velocity.x/2;
      sphereLocation.x = plateLength/2-sphereRadius;
    }
    if(sphereLocation.z + sphereRadius > plateLength/2){
      velocity.z = -velocity.z/2;
      sphereLocation.z = plateLength/2-sphereRadius;
    } else if(sphereLocation.z - sphereRadius < -plateLength/2){
      velocity.z = -velocity.z/2;
      sphereLocation.z = -plateLength/2+sphereRadius;
    }
  }
  
  void checkCylinderCollision(ArrayList<PVector> positions){
    Cylinder cylinder = new Cylinder();
    PVector normal;
    PVector normalized;
    PVector mappedCylinder = new PVector();
    for(PVector p: positions){
      
      //map the point from the referential of the adding-cylinders mode to the game's one
      mappedCylinder.x = map(p.x, leftSide, rightSide, -plateLength/2, plateLength/2);
      mappedCylinder.y = -plateHeight/2;
      mappedCylinder.z = map(p.y, topSide, bottomSide, -plateLength/2, plateLength/2);
      
      //check if there is a collisin between the ball and the cylinder
      if(overlap(sphereLocation, mappedCylinder)){
        normal = new PVector(sphereLocation.x - mappedCylinder.x, 0, sphereLocation.z - mappedCylinder.z);
        normalized = normal.normalize();
        sphereLocation.x = mappedCylinder.x + normalized.x * (sphereRadius +  cylinder.getBaseSize());
        sphereLocation.z = mappedCylinder.z + normalized.z * (sphereRadius +  cylinder.getBaseSize());
        PVector v = normalized.mult(1.5 * PVector.dot(velocity, normalized));
        velocity = velocity.sub(v);
      }
    }
  }
}

//definition of the cylinder class, which is used to display cylinders
class Cylinder {
  
  private float cylinderBaseSize = 20;
  private float cylinderHeight = 100;
  private int cylinderResolution = 40;
  
  PShape cylinderShape, openCylinder, topCylinder, bottomCylinder;
  
  Cylinder(){
    float angle;
    int mid = 0;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    mid = x.length / 2;
    float centerx = (x[mid] + x[0]) / 2;
    float centery = (y[mid] + y[0]) / 2;
    
    fill(cylinderColor);
    
    cylinderShape = createShape(GROUP);
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    topCylinder = createShape();
    bottomCylinder = createShape();
    topCylinder.beginShape(TRIANGLE_FAN);
    bottomCylinder.beginShape(TRIANGLE_FAN);
    
    topCylinder.vertex(centerx, centery, cylinderHeight);
    bottomCylinder.vertex(centerx, centery, 0);
    
    //draws the border of the cylinder
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i] , 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
      topCylinder.vertex(x[i], y[i], cylinderHeight);
      bottomCylinder.vertex(x[i], y[i], 0);
    }
    
    openCylinder.endShape();
    topCylinder.endShape();
    bottomCylinder.endShape();
    
    cylinderShape.addChild(topCylinder);
    cylinderShape.addChild(openCylinder);
    cylinderShape.addChild(bottomCylinder);
    
    }
    
    void update(){
      shape(cylinderShape);
    }
    
    void update(float x, float y){
      shape(cylinderShape, x, y);
    }
    
    float getBaseSize(){
      return cylinderBaseSize;
    }
}