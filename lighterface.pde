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

int startDrawingLineMillis = -1;

boolean drawLineInProgress = false;

void setup() {
  size(768, 768);
  middleX = width/2;
  middleY = height/2;
}

void draw() {
  int now = millis();
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

    if (dist(x, y, goalX, goalY) < goalCircleRadius) {
      drawLineInProgress = false;
    }
  } else {
    ellipse(middleX, middleY, goalCircleRadius, goalCircleRadius);
    if (dist(x, y, middleX, middleY) < goalCircleRadius) {
      fill(0, 100, 0);
      if (startDrawingLineMillis == -1) {
        // Start drawing line in three seconds.
        startDrawingLineMillis = now + 3000;
        println("three seconds to go...");
      } else if (startDrawingLineMillis < now) {
        // Start drawing line.
        println("start drawing line!");
        drawLineInProgress = true;
        line = PVector.random2D();
        line.setMag(300);
      }
    } else {
      // Not anymore inside start, try again.
      startDrawingLineMillis = -1;
      println("Resetting timer");
    }
  }
}
