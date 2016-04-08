//define the background color and the dimension of the sphere and the plate
float bgColor = 240;
float plateLength = 400;
float plateHeight = 20;
float sphereSize = 10;

//define the size of the window
int width = 1000;
int height = 600;

//define the coordinate of the 4 side of the plate in adding-cylinders mode
float leftSide = (width-plateLength)/2;
float rightSide = (width+plateLength)/2;
float topSide = (height-plateLength)/2;
float bottomSide = (height+plateLength)/2;

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

//size of the cylinder
float cylinderBaseSize = 10;
float cylinderHeight = 30;
int cylinderResolution = 40;

//define the mover and the sphereLocation
Mover mover;
PVector sphereLocation;

PShape cylinder, openCylinder, topCylinder, bottomCylinder;

ArrayList<PVector> cylinders = new ArrayList<PVector>();

void settings() {
  size(width, height, P3D);
}
void setup() {
  noStroke();
  
  mover = new Mover();
  
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides
  for(int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
  
  fill(cylinderColor);
  
  cylinder = createShape(GROUP);
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  topCylinder = createShape();
  topCylinder.beginShape(TRIANGLE);
  bottomCylinder = createShape();
  bottomCylinder.beginShape(TRIANGLE);
  
  //draw the cylinder
  for(int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i] , 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
    
    topCylinder.vertex(x[i], y[i] , cylinderHeight);
    topCylinder.vertex(0, 0, cylinderHeight);
    topCylinder.vertex(x[(i+1)%cylinderResolution], y[(i+1)%cylinderResolution] , cylinderHeight);
    
    bottomCylinder.vertex(x[i], y[i] , 0);
    bottomCylinder.vertex(0, 0, 0);
    bottomCylinder.vertex(x[(i+1)%cylinderResolution], y[(i+1)%cylinderResolution] , 0);
  }
  
  topCylinder.endShape();
  bottomCylinder.endShape();
  openCylinder.endShape();
  
  cylinder.addChild(topCylinder);
  cylinder.addChild(openCylinder);
  cylinder.addChild(bottomCylinder);
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

//method to bound the angle of the plate(X and Z axis)
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
  textSize(15);
  text("speed : " + speed,10, 20);
}

//draw the plate
void drawGame(){
  fill(plateColor);
  translate(width/2, height/2, 0);
  rotateX = map(angleX, -60, 60, -PI/3, PI/3);
  rotateZ = map(angleZ, -60, 60, -PI/3, PI/3);
  rotateX(rotateX);
  rotateZ(rotateZ);
  box(plateLength, plateHeight, plateLength);
  
  drawCylinders3D();
}

//draw the sphere
void drawSphere(){
  fill(sphereColor);
  mover.update();
  mover.checkEdges();
  mover.checkCylinderCollision();
  mover.display();
}

//draw the rectangle and the ball of the adding-cylinders mode
void drawViewMode(){
  
  fill(plateColor);
  pushMatrix();
  
    //draw the rectangle at the center of the window
    translate(width/2, height/2,0);
    rect(-plateLength/2, -plateLength/2, plateLength, plateLength);
    
    //draw the ball according to the current position of the sphere
    fill(sphereColor);
    ellipse(sphereLocation.x,sphereLocation.z , sphereSize, sphereSize);
  popMatrix();
}

//draw the cylinders in the adding-cylinders mode
void drawCylinders2D(){
  PVector cylinderVector = new PVector();
  for(int i = 0; i < cylinders.size(); i++){
    cylinderVector = cylinders.get(i);
    shape(cylinder, cylinderVector.x, cylinderVector.y);
  }
}

//draw the cylinders on the game
void drawCylinders3D(){
  PVector cylinderVector = new PVector();
  for(int i = 0; i < cylinders.size(); i++){
    cylinderVector = cylinders.get(i);
    pushMatrix();
      translate(map(cylinderVector.x, leftSide, rightSide, -200, 200), -10, map(cylinderVector.y, topSide, bottomSide, -200, 200));
      rotateX(HALF_PI);
      shape(cylinder);
    popMatrix();
  }
}

void mouseReleased(){
  //test if we are in view mode
  if(keyPressed && keyCode == SHIFT){
    if(check() && !overlap(sphereLocation, new PVector(map(mouseX, leftSide, rightSide, -200, 200), -10, map(mouseY, topSide, bottomSide, -200, 200)))){
      cylinders.add(new PVector(mouseX, mouseY));
    }
  }
}

//check if the cylinder is on the plate and if he is not on another cylinder or on the ball
boolean check(){
  if(mouseX + cylinderBaseSize <= rightSide && mouseX - cylinderBaseSize >= leftSide
        && mouseY + cylinderBaseSize <= bottomSide && mouseY - cylinderBaseSize >= topSide){
    return true;
  }
  return false;
}

boolean overlap(PVector sphere, PVector cylinder){
  if(sphere.x <= cylinder.x + cylinderBaseSize && sphere.x >= cylinder.x - cylinderBaseSize 
          && sphere.z <= cylinder.z + cylinderBaseSize && sphere.z >= cylinder.z - cylinderBaseSize){
    return true;
  }
  return false;
}


class Mover {
  
  //physic contants
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  float gravityConstant = 0.2;
  
  PVector velocity;
  PVector gravityForce;
  PVector friction;
  
  Mover() {
    sphereLocation = new PVector(0, -plateHeight, 0);
    velocity = new PVector();
    gravityForce = new PVector(0, 0, 0);
    friction = new PVector();
  }
  
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
  
  void display() {
    translate(sphereLocation.x, sphereLocation.y, sphereLocation.z);
    sphere(sphereSize);
  }
  
  void checkEdges() {
    if(sphereLocation.x - sphereSize < -plateLength/2){
      velocity.x = abs(velocity.x)/2;
      sphereLocation.x = -plateLength/2+sphereSize;
    } else if(sphereLocation.x + sphereSize > plateLength/2){
      velocity.x = -abs(velocity.x)/2;
      sphereLocation.x = plateLength/2-sphereSize;
    }
    if(sphereLocation.z + sphereSize > plateLength/2){
      velocity.z = -abs(velocity.z)/2;
      sphereLocation.z = plateLength/2-sphereSize;
    } else if(sphereLocation.z - sphereSize < -plateLength/2){
      velocity.z = abs(velocity.z)/2;
      sphereLocation.z = -plateLength/2+sphereSize;
    }
  }
  
  void checkCylinderCollision(){
    PVector cylinder = new PVector();
    PVector mappedCylinder = new PVector();
    for(int i = 0; i < cylinders.size(); i++){
      cylinder = cylinders.get(i);
      
      mappedCylinder.x = map(cylinder.x, leftSide, rightSide, -200, 200);
      mappedCylinder.y = -plateHeight;
      mappedCylinder.z = map(cylinder.y, topSide, bottomSide, -200, 200);
      
      if(overlap(sphereLocation, mappedCylinder)){
        
        PVector n = sphereLocation.sub(mappedCylinder);
        n.y = 0;
        sphereLocation = mappedCylinder.add(n);
        n = n.normalize();
        
        velocity.sub(n.mult(1.5*velocity.dot(n)));
        velocity.y = 0;
      }
    }
  }
}