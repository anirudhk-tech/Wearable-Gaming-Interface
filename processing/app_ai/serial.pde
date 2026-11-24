import processing.serial.*;

String PORT_NAME = "/dev/ttyACM0";
int baudrate = 115200;
Serial port;
// spectra, fsr, x, y, z, c0, c1, c2, c3
String[] values = new String[10]; // 9 -> 5 are fixed and 4 are variables
float spectra, fsr, c0, c1, c2, c3;
float x, y, z;

void setupSerial() {
    printArray(Serial.list());
    port = new Serial(this, PORT_NAME, baudrate);
    port.bufferUntil('\n');
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line == null) return;
  line = trim(line);
  println("serial: " + line);

  values = splitTokens(line, ",");
  if (values == null || values.length < 5) return;
  
  println("values.length: " + values.length);
  
  spectra = float(values[0]);
  fsr = float(values[1]);
  println("fsr: " + fsr);
  
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
