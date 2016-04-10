float scale = 1;
float rotateX = 0;
float rotateY = 0;

void settings() {
size(1000, 1000, P2D);
}

void setup() {
}
void draw() {
  background(255);
  My3DPoint eye = new My3DPoint(-100, -100, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
  My3DBox input3DBox = new My3DBox(origin, 100,150,300);
  
  textSize(20);
  text("Press(hold) right or left to rotate around Y axis", 300, 100);
  text("Press(hold) up or down to rotate around X axis", 300, 150);
  text("Click and drag to increase(decrease) size", 300, 200);
  fill(0, 102, 153);
  
  float[][] transformScale = scaleMatrix(scale, scale, scale);
  
  
  //Can hold button instead of clicking
  if(keyPressed == true){
      if(keyCode == UP){
        rotateX += Math.PI/24;
      }  
       if(keyCode == DOWN){
        rotateX += -Math.PI/24 ;
      }
      
      if(keyCode == RIGHT){
        rotateY += Math.PI / 24;
      }
      if(keyCode == LEFT){
        rotateY += -Math.PI / 24;
      }
    }
  
  float[][] transformRotx = rotateXMatrix(rotateX);
  float[][] transformRoty = rotateYMatrix(rotateY);
  
  input3DBox = transformBox(input3DBox, transformScale);
  input3DBox = transformBox(input3DBox, transformRotx);
  input3DBox = transformBox(input3DBox, transformRoty);
  projectBox(eye, input3DBox).render();

}

void mouseDragged() 
{
  if(scale < 0)
    scale = 0;
  if(pmouseY < mouseY)
    scale += 0.03;
  else
    scale -= 0.03;
}

/*
------------------------------DEFINITION OF A 2D POINT------------------------------
*/

class My2DPoint {
   float x;
   float y;
   
   My2DPoint(float x, float y) {
      this.x = x;
      this.y = y;
   }
}

class My3DPoint {
   float x;
   float y;
   float z;
   
   My3DPoint(float x, float y, float z) {
      this.x = x;
      this.y = y;
      this.z = z;
   }
}

class My2DBox {
  My2DPoint[] s;
  
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  
  void render() {
    for(int i = 0; i < s.length;i++) {
      if(i%8 < 4) {
        line(s[i].x, s[i].y, s[(i+1)%4].x, s[(i+1)%4].y);
        line(s[i].x, s[i].y, s[i+4].x, s[i+4].y);
      }
      else {
        line(s[i].x, s[i].y, s[(i+1)%4+4].x, s[(i+1)%4+4].y);
      }
    }
  }
}

/*
------------------------------DEFINITION OF A 3D POINT------------------------------
*/
class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x,y+dimY,z+dimZ),
                             new My3DPoint(x,y,z+dimZ),
                             new My3DPoint(x+dimX,y,z+dimZ),
                             new My3DPoint(x+dimX,y+dimY,z+dimZ),
                             new My3DPoint(x,y+dimY,z),
                             origin,
                             new My3DPoint(x+dimX,y,z),
                             new My3DPoint(x+dimX,y+dimY,z)
                            };
  }
  
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
   return new My2DPoint(-(p.x - eye.x)*eye.z/(p.z - eye.z), -(p.y - eye.y)*eye.z/(p.z - eye.z)); 
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint[] s = new My2DPoint[8];
  for(int i = 0; i < 8; i++){
    s[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(s);
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] points = new My3DPoint[8];
  for(int i = 0; i < 8; i++){
    points[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(points);
}

My3DPoint euclidian3DPoint(float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

/*
------------------------------MATRIX TRANSFORMATION------------------------------
*/

float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float [][] { {1, 0, 0, 0},
                          {0, cos(angle), sin(angle), 0},
                          {0, -sin(angle), cos(angle), 0},
                          {0, 0, 0, 1,}});
}

float[][] rotateYMatrix(float angle) {
  return(new float [][] { {cos(angle), 0, sin(angle), 0},
                          {0, 1, 0, 0},
                          {sin(angle), 0, cos(angle), 0},
                          {0, 0, 0, 1,}});
}

float[][] rotateZMatrix(float angle) {
  return(new float [][] { {cos(angle), sin(angle), 0, 0},
                          {-sin(angle), cos(angle), 0, 0},
                          {0, 0, 1, 0},
                          {0, 0, 0, 1,}});
}

float[][] scaleMatrix(float x, float y, float z){
  return(new float [][] { {x, 0, 0, 0},
                          {0, y, 0, 0},
                          {0, 0, z, 0},
                          {0, 0, 0, 1,}});
}

float[][] translationMatrix(float x, float y, float z){
  return(new float [][] { {1, 0, 0, x},
                          {0, 1, 0, y},
                          {0, 0, 1, z},
                          {0, 0, 0, 1,}});
}

float[] matrixProduct(float[][] a, float[] b){
  float[] result = new float[4];
  
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      result[i] += a[i][j]*b[j];
    }
  }
  return result;
}