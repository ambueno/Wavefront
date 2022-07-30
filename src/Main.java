import java.util.*;
import processing.core.*;

//

Matrix matrix;

final int gridSize = 50;
final int numberOfObstacles = 900;
final int ROBOT_VALUE = -2, END_VALUE = -3, OBSTACLE_VALUE = 0, PATH_VALUE = -5;
final int[][] adjacentsArray = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}};
final float gap = .1;

//

boolean isImpossible = false;
boolean foundEnd = false;

//

int cellWidth;
int cellHeight;
float angle;
float sizeFactor;

//

int counter;
int wavefrontTimer;
int[][] path;
int pathProgress;
int simulationTimer;

//

void setup(){  
  size(900, 900, P3D);
  
  angle = atan(-QUARTER_PI);
  sizeFactor = 0.7;
  cellWidth = int(width * sizeFactor / gridSize);
  cellHeight = int(height * sizeFactor / gridSize);
  
  matrix = new Matrix();
  matrix.buildGrid();
  
  pathProgress = 0;
  thread("Execute");
}

void Execute(){
  delay(1000);
  if(matrix.Wavefront()){
    delay(1000);
    matrix.buildPath();
  } else {
    isImpossible = true;
  }
}

void draw(){
  background(0);
  
  ortho();
  translate(width / 2, height / 2, 0);
  
  ambientLight(63, 63, 63);
  directionalLight(255, 255, 255, 50, 50, -100);
  
  rotateX(angle - .2 + sin(millis() / 1000f) * .2);
  rotateY(-QUARTER_PI + millis() / 5000f);
  translate(-width * sizeFactor / 2, 0, -height * sizeFactor / 2);

  matrix.display();
  saveFrame();
}
