/**
 * Lighterface - user interface research based on two photoresistors
 *
 * Two photoresistors gives a pointer's x and y coordinates. The task is to
 * write straight lines. We need a way to show this goal and make sampling of
 * the path taken when writing the line with a tricky control scheme.
 */

// Line to draw
PVector line;

int middleX, middleY;

int goalCircleRadius = 50;

int startDrawingLineInMillis = -1;

boolean drawLineInProgress = false;

ArrayList<Integer> pointerXCoordinates = new ArrayList<Integer>();
ArrayList<Integer> pointerYCoordinates = new ArrayList<Integer>();
ArrayList<Integer> pointerMillis = new ArrayList<Integer>();
int startDrawingLineMillis;

int now = 0;

PrintWriter output;

void setup() {
  size(768, 768);
  middleX = width/2;
  middleY = height/2;
  newFileWithHeader();
}

void newFileWithHeader() {
  output = createWriter("results" + millis() + ".txt");
  output.println("x,y,milliseconds")
}

void draw() {
  now = millis();
  fill(100, 0.8);

  // TODO: fix fading
  rect(0, 0, width, height);
  background(100);

  int x = mouseX;
  int y = mouseY;

  // Plot the cursor
  fill(255);
  ellipse(mouseX, mouseY, 5, 5);

  // Start drawing the line from the middle. Denote this region with a circle
  fill(100);
  if (drawLineInProgress) {
    float goalX = middleX + line.x;
    float goalY = middleY + line.y;

    // Draw the line
    line(middleX, middleY, goalX, goalY);

    // Draw goal circle
    fill(0, 100, 0);
    ellipse(goalX, goalY, goalCircleRadius, goalCircleRadius);

    pointerXCoordinates.add(x);
    pointerYCoordinates.add(y);
    pointerMillis.add(now-startDrawingLineMillis);

    if (dist(x, y, goalX, goalY) < goalCircleRadius) {
      drawLineInProgress = false;
      for (int i = 0; i < pointerXCoordinates.size(); i++) {
        output.print(pointerXCoordinates.get(i));
        output.print(",");
        output.print(pointerYCoordinates.get(i));
        output.print(",");
        output.println(pointerMillis.get(i));
      }
      output.flush(); // Writes the remaining data to the file
      output.close(); // Finishes the file
      output = newFileWithHeader();
      pointerXCoordinates.clear();
      pointerYCoordinates.clear();
      pointerMillis.clear();
    }
  } else {
    ellipse(middleX, middleY, goalCircleRadius, goalCircleRadius);
    if (dist(x, y, middleX, middleY) < goalCircleRadius) {
      fill(0, 100, 0);
      if (startDrawingLineInMillis == -1) {
        // Start drawing line in three seconds.
        startDrawingLineInMillis = now + 3000;
      } else if (startDrawingLineInMillis < now) {
        // Start drawing line.
        drawLineInProgress = true;
        startDrawingLineMillis = now;
        line = PVector.random2D();
        line.setMag(300);
      }
    } else {
      // Not anymore inside start, try again.
      startDrawingLineInMillis = -1;
    }
  }
}
