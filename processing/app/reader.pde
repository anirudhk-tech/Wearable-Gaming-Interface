// Book Reader settings
ArrayList<String> readerPages = new ArrayList<String>();
int currentPage = 0;
String bookTitle = "My Book";
float readerFontSize = 18, maxSize = 30, minSize = 12;

// Cooldown timer so one tilt only flips one page at a time
int lastFlipTime = 0;
int flipCooldown = 1000; // milliseconds between actions

int charsPerPage = 1500;
String fullText;

void setupReader() {
  // Place a "book.txt" file inside your sketch's "data" folder
  String[] lines = loadStrings("book.txt");
  
  // Fallback sample text if book.txt isn't added yet
  if (lines != null && lines.length > 0) {
    fullText = join(lines, "\n");
  } else {
    fullText = "Chapter 1\n\nPlace a 'book.txt' file inside your sketch's data folder to load your own story. " +
               "Tilt RIGHT to turn to the next page, tilt LEFT to go back, and tilt UP or DOWN to adjust the font size.\n\n" +
               "Because Processing wraps text inside a bounding box automatically, building an e-reader UI is clean and lightweight.";
  }

  paginateBook(fullText, charsPerPage); // ~900 characters per page (adjust to fit your window)
  currentPage = 0;
}

void drawReader() {
  background(245, 240, 230); // Warm paper-like background

  // 1. Handle Tilt Inputs with Cooldown
  if (millis() - lastFlipTime > flipCooldown) {
    if (currentDirection == RIGHT && currentPage < readerPages.size() - 1) {
      currentPage++;
      lastFlipTime = millis();
    } else if (currentDirection == LEFT && currentPage > 0) {
      currentPage--;
      lastFlipTime = millis();
    } else if (currentDirection == UP && readerFontSize < maxSize) {
    //} else if (currentDirection == UP && readerFontSize < maxSize) { // pressed c0
      readerFontSize += 2;
      charsPerPage = int(1500 * (18.0 / readerFontSize));
      paginateBook(fullText, charsPerPage);
      lastFlipTime = millis();
    } else if (currentDirection == DOWN && readerFontSize > minSize) {
    //} else if (currentDirection == DOWN && readerFontSize > minSize) { // pressed c1
      readerFontSize -= 2;
      charsPerPage = int(1500 * (18.0 / readerFontSize));
      paginateBook(fullText, charsPerPage);
      lastFlipTime = millis();
    }
  }

  // 2. Draw Page Card & Margins
  float marginX = width * 0.25;
  float marginY = height * 0.12;
  float boxW = width - (marginX * 2);
  float boxH = height - (marginY * 2);

  fill(255);
  stroke(210);
  rect(marginX - 20, marginY - 20, boxW + 40, boxH + 40, 8);

  // 3. Draw Header (Book Title & Font Size)
  fill(120);
  textSize(14);
  textAlign(LEFT, BOTTOM);
  text(bookTitle, marginX, marginY - 28);
  textAlign(RIGHT, BOTTOM);
  text("Text Size: " + int(readerFontSize) + "pt\n" + " chars: " + charsPerPage, width - marginX, marginY - 28);

  // 4. Draw Current Page Text (Processing auto-wraps inside boxW, boxH)
  fill(30);
  textSize(readerFontSize);
  textLeading(readerFontSize * 1.45); // Comfortable line spacing
  textAlign(LEFT, TOP);
  if (readerPages.size() > 0) {
    text(readerPages.get(currentPage), marginX, marginY, boxW, boxH);
  }

  // 5. Draw Footer (Page Counter & Tilt Hints)
  fill(120);
  textSize(14);
  textAlign(CENTER, TOP);
  text("Page " + (currentPage + 1) + " of " + readerPages.size(), width / 2, height - marginY + 28);

}

// Splits the full text into clean pages without cutting words in half
void paginateBook(String text, int charsPerPage) {
  readerPages.clear();
  int start = 0;
  while (start < text.length()) {
    int end = min(start + charsPerPage, text.length());
    // Step back to the nearest space or newline so words don't split mid-word
    if (end < text.length()) {
      int lastSpace = text.lastIndexOf(' ', end);
      int lastNewline = text.lastIndexOf('\n', end);
      int breakPoint = max(lastSpace, lastNewline);
      if (breakPoint > start) {
        end = breakPoint;
      }
    }
    readerPages.add(trim(text.substring(start, end)));
    start = end;
  }
}
