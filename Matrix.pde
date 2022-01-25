public class Matrix { 
  private int[] robotCoordinate;
  private int[] endCoordinate;
  private Hashtable <Coordinate, Integer> matrix;
  
  public Matrix() {
    robotCoordinate = new int[2];
    endCoordinate = new int[2];
    matrix = new Hashtable <Coordinate, Integer>(numberOfObstacles + 2);
  }
  
  public void buildGrid() {
    this.attributeValues();
  }
  
  private void attributeValues() {
    randomCoordGenerator(ROBOT_VALUE);
    while (randomCoordGenerator(END_VALUE) != null);
    int obstaclesPlaced = 0;
    while (obstaclesPlaced < numberOfObstacles) {
      if ((randomCoordGenerator(OBSTACLE_VALUE) == null)) obstaclesPlaced++;
    }
  }
  
  private Integer randomCoordGenerator(int value) {
    int auxI = (int)random(gridSize);
    int auxY = (int)random(gridSize);
    
    if (value == ROBOT_VALUE) {
      robotCoordinate[0] = auxI;
      robotCoordinate[1] = auxY;
    } else if (value == END_VALUE) {
      endCoordinate[0] = auxI;
      endCoordinate[1] = auxY;
    }
    return (this.matrix.putIfAbsent(new Coordinate(auxI, auxY), value));
  }
  
  public void display() {
    stroke(#C4C4C4);
    strokeWeight(1);
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        pushMatrix();
          translate(i * cellWidth + cellWidth / 2., 5000, j * cellHeight + cellHeight / 2.);
          Coordinate auxCoordinate = new Coordinate(i, j);
          if (this.matrix.containsKey(auxCoordinate)) {
            int value = this.matrix.get(auxCoordinate);
            if (value == ROBOT_VALUE) {
              fill(#80FFDB);
              box(cellWidth, 10000, cellHeight);
            } else if (value == END_VALUE) {
              float t = constrain((millis() - wavefrontTimer) / 200., 0., 1.) - 1;
              fill(#7400B8);
              translate(0, max(counter + t - 1, 0) * cellWidth * gap, 0);
              box(cellWidth, 10000, cellHeight);
            } else if (value > 0) {
              float t = constrain((millis() - wavefrontTimer) / 200., 0., 1.) - 1;
              int colour = lerpColor(#AA16FF, #ADFFE8, (float) value / (counter + t));
              fill(colour);
              translate(0, max(counter - value + t - 1, 0) * cellWidth * gap, 0);
              box(cellWidth, 10000, cellHeight);
            } else {
              fill(0);
              translate(0, -.2 * cellWidth, 0);
              box(cellWidth, 10000, cellHeight);
            }
          } else {
            fill(255);
            box(cellWidth, 10000, cellHeight);
          }
        popMatrix();
      }
    }
    pushMatrix();
      if (pathProgress == 0) {
        translate(robotCoordinate[0] * cellWidth + cellWidth / 2., - cellWidth / 2., robotCoordinate[1] * cellHeight + cellHeight / 2.);
        fill(#80FFDB);
        noStroke();
        sphere(cellWidth / 2.);
      }
      else {
        int ballI = robotCoordinate[0], ballJ = robotCoordinate[1];
        translate(cellWidth / 2., - cellWidth / 2., cellHeight / 2.);
        noFill();
        strokeWeight(cellWidth * .2);
        strokeJoin(ROUND);
        stroke(#7400B8);
        beginShape();
          vertex(ballI * cellWidth, 0, ballJ * cellHeight);
          vertex(ballI * cellWidth, 0, ballJ * cellHeight);
          for (int i = 0; i < pathProgress - 1; i++) {
            ballI += path[i][0];
            ballJ += path[i][1];
            Coordinate node = new Coordinate(ballI, ballJ);
            int node_value = matrix.get(node);
            vertex(ballI * cellWidth, (counter - node_value - 1) * cellWidth * gap, ballJ * cellHeight);
          }
          int value = matrix.get(new Coordinate(ballI, ballJ));
          float time = constrain((millis() - simulationTimer) / 300., 0., 1.);
          float h = time * time, m = 2 * time - time * time;
          float posI = ballI + path[pathProgress - 1][0] * m, posJ = ballJ + path[pathProgress - 1][1] * m;
          if (value == ROBOT_VALUE) vertex(posI * cellWidth, h * cellWidth * gap, posJ * cellHeight);
          else vertex(posI * cellWidth, (counter - value + h - 1) * cellWidth * gap, posJ * cellHeight);
        endShape();
        if (value == ROBOT_VALUE)translate(posI * cellWidth, time * cellWidth * gap, posJ * cellHeight);
        else translate(posI * cellWidth, (counter - value + h - 1) * cellWidth * gap, posJ * cellHeight);
        fill(#80FFDB);
        noStroke();
        sphere(cellWidth / 2.);
      }
    popMatrix();
  }
  
  public boolean Wavefront() {
    counter = 1;
    while (!foundEnd) {
      boolean changed = false;
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          Coordinate current = new Coordinate(i, j);
          if (!(matrix.containsKey(current) && (counter == 1 && matrix.get(current) == END_VALUE || counter > 1 && matrix.get(current) == counter - 1))) continue;
          for (int[] adjacent : adjacentsArray) {
            Coordinate auxCoordinate = new Coordinate(i + adjacent[0], j + adjacent[1]);
            if (i + adjacent[0] < 0 || j + adjacent[1] < 0 || i + adjacent[0] >= gridSize || j + adjacent[1] >= gridSize) continue;
            if (matrix.containsKey(auxCoordinate) && matrix.get(auxCoordinate) == ROBOT_VALUE) foundEnd = true;
            else if (!(this.matrix.containsKey(auxCoordinate))) {
              this.matrix.put(auxCoordinate, counter);
              changed = true;
            }
          }
        }
      }
      if (!changed && !foundEnd) break;
      counter++;
      wavefrontTimer = millis();
      delay(200);
    }
    return foundEnd;
  }
  
  public void buildPath() {
    path = new int[counter - 1][];
    int step = counter - 2;
    int initialX = robotCoordinate[0], initialY = robotCoordinate[1];
    while(step >= 0) {
      for (int[] adjacent : adjacentsArray) {
        Coordinate auxCoordinate = new Coordinate(initialX + adjacent[0], initialY + adjacent[1]);
        if (this.matrix.containsKey(auxCoordinate) && (step > 0 && this.matrix.get(auxCoordinate) == step || this.matrix.get(auxCoordinate) == END_VALUE)) {
          initialX = auxCoordinate.getI();
          initialY = auxCoordinate.getJ();
          path[pathProgress] = adjacent;
          pathProgress++;
          simulationTimer = millis();
          break;
        }
      }
      step--;
      delay(300);
    }
  }
}
