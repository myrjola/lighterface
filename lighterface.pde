/**
 * Lighterface - user interface research based on two photoresistors
 *
 * Two photoresistors gives a pointer's x and y coordinates. The task
 * is to write straight lines. We need a way to show this goal and
 * make sampling of the path taken when writing the line with a tricky
 * control scheme.
 */

import processing.serial.*;

import cc.arduino.*;

final int ANALOG_MAX = 1023;

Arduino arduino;

// Line to draw
PVector line;

int middleX, middleY;

int goalCircleRadius = 50;

int startDrawingLineInMillis = -1;

int minX = ANALOG_MAX;
int minY = ANALOG_MAX;
int maxX = 0;
int maxY = 0;

boolean drawLineInProgress = false;

// Change this to false when you want to control the pointer with an
// Arduino's 0 and 1 analog ports.
boolean mousePointer = true;

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

  if (!mousePointer) {
    // Prints out the available serial ports.
    println(Arduino.list());

    // Modify this line, by changing the "0" to the index of the serial
    // port corresponding to your Arduino board (as it appears in the list
    // printed by the line above).
    arduino = new Arduino(this, Arduino.list()[5], 57600);
  }
}

void newFileWithHeader() {
  output = createWriter("results" + day() + "_" + month() + "_" + year() +
                        "_" + hour() + minute() + second() + ".csv");
  output.println("x,y,milliseconds");
  int halfWidth = width / 2;
  int halfHeight = height / 2;
  output.println(halfWidth + "," + halfHeight + ",0");
}

void draw() {
  now = millis();
  fill(100, 0.8);

  background(100);

  int x = mouseX;
  int y = mouseY;

  if (!mousePointer) {
    x = arduino.analogRead(0);
    y = arduino.analogRead(1);

    if (x > maxX) {
      maxX = x;
    } else if (x < minX) {
      minX = x;
    }
    if (y > maxY) {
      maxY = y;
    } else if (y < minY) {
      minY = y;
    }

    println("x = " + x);
    println("y = " + y);

    x = int(map(x, minX, maxX, 0, width));
    y = int(map(y, minY, maxY, 0, height));

    println("x = " + x);
    println("y = " + y);
    println("minX = " + minX);
    println("minY = " + minY);
    println("maxX = " + maxX);
    println("maxY = " + maxY);
  }

  // Plot the cursor
  fill(255);
  ellipse(x, y, 5, 5);

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
      output.print(int(goalX));
      output.print(",");
      output.print(int(goalY));
      output.print(",");
      output.println(now-startDrawingLineMillis);
      output.flush(); // Writes the remaining data to the file
      output.close(); // Finishes the file
      newFileWithHeader();
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
