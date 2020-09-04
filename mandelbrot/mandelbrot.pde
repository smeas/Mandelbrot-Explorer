/*
 * Made by: Jonatan Johansson
 *
 * Controls:
 * w, a, s, d  - Pan
 * up, down    - Zoom
 * left, right - Iteration count
 * p           - Save image
 */

final int FRAME_TIME_BUDGET = 16*2; // max time in milliseconds to spend calculating per frame
final float TRANSLATE_STEP = 0.1;   // step size for translation/panning
final float SCALE_STEP = 1 - 0.1;   // step size for scaling/zooming

// State
boolean done;         // frame done?
int px, py;           // current pixel
float tx, ty;         // translation
float sx = 1, sy = 1; // scale
int iterations = 64;


void setup() {
  size(800, 800);
  background(0);
}

void draw() {
  if (done) return;

  int frameStart = millis();

loop:
  for (; py < height; py++) {
    for (; px < width; px++) {
      float x = map((float)px, 0, width, -2 / sx + tx, 2 / sx + tx);
      float y = map((float)py, 0, height, -2 / sy + ty, 2 / sy + ty);
      int val = (int)(mandel(x, y) * 256);

      set(px, py, color(val, val, val));

      if (millis() - frameStart > FRAME_TIME_BUDGET) {
        break loop;
      }
    }

    px = 0;
  }

  if (px == width && py == height) {
    done = true;
    px = py = 0;
    println("Done!");
  }
}

void keyPressed() {
  boolean invalidate = true;

  if (key == 'w') { // up
    ty += -TRANSLATE_STEP * (1.0 / sy);
  } else if (key == 's') { // down
    ty += TRANSLATE_STEP * (1.0 / sy);
  } else if (key == 'a') { // left
    tx += -TRANSLATE_STEP * (1.0 / sx);
  } else if (key == 'd') { // right
    tx += TRANSLATE_STEP * (1.0 / sx);
  } else if (keyCode == UP) { // zoom in
    sx /= SCALE_STEP;
    sy /= SCALE_STEP;
  } else if (keyCode == DOWN) { // zoom out
    sx *= SCALE_STEP;
    sy *= SCALE_STEP;
  } else if (keyCode == RIGHT) { // iterations up
    iterations *= 2;
    println("iterations: " + str(iterations));
  } else if (keyCode == LEFT) { // iterations down
    iterations = max(1, iterations / 2);
    println("iterations: " + str(iterations));
  } else if (key == 'r') { // reset
    tx = ty = 0;
    sx = sy = 1;
  } else {
    if (key == 'p') {
      println("Saving image...");
      saveFrame("mandelbrot-####.png");
    }

    invalidate = false;
  }

  if (invalidate) {
    px = py = 0;
    done = false;
  }
}

// (a + bi)^2
// = a^2 - b^2 + 2abi
float mandel(float px, float py) {
  float zx = 0, zy = 0;
  int i;
  for (i = 0; i < iterations; i++) {
    // square z and add p
    float tx = zx*zx - zy*zy + px;
    zy = 2*zx*zy + py;
    zx = tx;

    if (zx*zx + zy*zy > 2*2)
      break;
  }

  return (float)i / iterations;
}
