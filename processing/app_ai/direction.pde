// Direction constants
final int NEUTRAL = 0;
final int RIGHT   = 1;
final int UP      = 2;
final int LEFT    = 3;
final int DOWN    = 4;

// Baseline calibration variables
boolean calibrated = false;
int sampleCount = 0;
final int TOTAL_SAMPLES = 25;
int sumY = 0, sumZ = 0;
int baseY = 0, baseZ = 0;

// Sensitivity threshold (raw MPU units; ~16384 = 90 degrees)
final float THRESHOLD = 2500;

int currentDirection = NEUTRAL;
float diffY = 0, diffZ = 0;



int detectDirection(float dY, float dZ) {
  if (abs(dY) > abs(dZ)) {
    if (dY > THRESHOLD)  return DOWN;  // 4
    if (dY < -THRESHOLD) return UP;    // 2
  } else {
    if (dZ > THRESHOLD)  return RIGHT; // 1
    if (dZ < -THRESHOLD) return LEFT;  // 3
  }
  return NEUTRAL; // 0
}
