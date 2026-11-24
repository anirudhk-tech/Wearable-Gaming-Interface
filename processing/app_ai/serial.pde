import processing.serial.*;

// Two wearable connections. Parsing + calibration logic is the same as app/serial.pde,
// just held per-sensor so each player has their own.
String[] PORT_NAMES = {"/dev/ttyACM0", "/dev/ttyACM1"};
int baudrate = 115200;
Sensor[] sensors = new Sensor[2];

class Sensor {
  Serial port;
  boolean connected = false;
  // spectra, fsr, x, y, z, c0, c1, c2, c3
  String[] values = new String[10];
  float spectra, fsr, c0, c1, c2, c3;
  float x, y, z;

  boolean calibrated = false;
  int sampleCount = 0;
  int sumY = 0, sumZ = 0;
  int baseY = 0, baseZ = 0;
  int currentDirection = NEUTRAL;
  float diffY = 0, diffZ = 0;

  Sensor(PApplet parent, String name) {
    try {
      port = new Serial(parent, name, baudrate);
      port.bufferUntil('\n');
      connected = true;
    } catch (Exception e) {
      println("sensor not found: " + name);
    }
  }

  void recalibrate() {
    calibrated = false;
    sampleCount = 0;
    sumY = 0;
    sumZ = 0;
    currentDirection = NEUTRAL;
  }

  void handle(String line) {
    values = splitTokens(line, ",");
    if (values == null || values.length < 5) return;

    spectra = float(values[0]);
    fsr = float(values[1]);

    x = float(values[2]);
    y = float(values[3]);
    z = float(values[4]);

    if (!calibrated) {
      sumY += y;
      sumZ += z;
      sampleCount++;

      if (sampleCount >= TOTAL_SAMPLES) {
        baseY = sumY / TOTAL_SAMPLES;
        baseZ = sumZ / TOTAL_SAMPLES;
        calibrated = true;
        currentDirection = NEUTRAL;
      }
    } else {
      diffY = y - baseY;
      diffZ = z - baseZ;
      currentDirection = detectDirection(diffY, diffZ);
    }

    if (values.length > 5) c0 = float(values[5]);
    if (values.length > 6) c1 = float(values[6]);
    if (values.length > 7) c2 = float(values[7]);
    if (values.length >= 8) c3 = float(values[8]);
  }
}

void setupSerial() {
  printArray(Serial.list());
  for (int i = 0; i < 2; i++) sensors[i] = new Sensor(this, PORT_NAMES[i]);
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line == null) return;
  line = trim(line);
  for (int i = 0; i < 2; i++) {
    if (sensors[i] != null && sensors[i].port == p) sensors[i].handle(line);
  }
}
