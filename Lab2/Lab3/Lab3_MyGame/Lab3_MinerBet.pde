int totalAmount;
int betAmount;
int potentialWin;
float totalSquares;
float multiplier;
int gameState;
int gridSize;
int opened;
int bombIndex;
int gap;
int squareSize;
int squareX0;
int squareY;
int squareX;
boolean clickHandled = false;

color buttonIn = color(245, 218, 167);
color buttonOut = color(163, 72, 90);
color bgLight = color(132, 42, 59);
color bgDark = color(102, 34, 34);
color greenSafe = color(144, 238, 144);
color redBomb = color(255, 100, 100);

ArrayList<Square> squares;

class Square {
  int x;
  int y;
  int size;
  int index;
  boolean opened;
  boolean isBomb;
  
  Square(int x, int y, int size, int index, boolean isBomb) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.index = index;
    this.opened = false;
    this.isBomb = isBomb;
  }
  
  void display() {
    rectMode(CENTER);
    if (opened) {
      textAlign(CENTER, CENTER);
      textSize(size * 0.6);
      if (isBomb) {
        fill(redBomb);
        rect(x, y, size, size, 10);
        fill(0);
        text("X", x, y);
      } else {
        fill(greenSafe);
        rect(x, y, size, size, 10);
        fill(255);
        text("$", x, y);
      }
    } else {
      fill(buttonIn);
      rect(x, y, size, size, 10);      
    }
  }
  
  boolean isClicked(int mx, int my) {
    return abs(mx - x) <= size/2 && abs(my - y) <= size/2;
  }
}

void setup() {
  size(600, 450); // 300x400 is mimnimal, but 600x500 is recommended
  gameState = 0;
  totalAmount = 1000;
  betAmount = 100;
  gridSize = 4;
  gap = 12;
  opened = 0;
  potentialWin = 0;
  squares = new ArrayList<Square>();
  
  noStroke();
}

void tab() {
  background(bgLight);
  rectMode(CORNERS);
  fill(bgDark);
  rect(0, 0, 200, height);
  fill(buttonOut);
  rect(20, 40, 180, 80, 10);
  rect(20, 120, 180, 160, 10);
  rect(20, 200, 180, 240, 10);
  fill(buttonIn);
  rect(20, 260, 180, 300, 10);
  fill(buttonOut);
  rect(60, 310, 140, 330, 10);
  
  // BUTTONS
  fill(buttonIn);
  rectMode(CENTER);
  
  rect(100, 140, 50, 34, 10);
  rect(48, 140, 50, 34, 10);
  rect(152, 140, 50, 34, 10);  
  
  rect(100, 220, 50, 34, 10);
  rect(48, 220, 50, 34, 10);
  rect(152, 220, 50, 34, 10);  
  
  // TEXT
  fill(255);
  textSize(17);
  textAlign(LEFT, CENTER);
  text("Total Amount", 23, 25);
  text("Grid size", 23, 105);
  text("Bet Amount", 23, 185);
  text("$" + totalAmount, 30, 60);
  
  textAlign(CENTER, CENTER);
  fill(bgDark);
  text("x3", 48, 140); 
  text("x4", 100, 140); 
  text("x5", 152, 140);  
  text("100", 48, 220);  
  text("300", 100, 220);  
  text("All", 152, 220);  
  text("Bet", 100, 280);
  text("exit", 100, 320);
  
  // Game explanation: the game is already popular, but i had to it because of the criteria
  // Difficulty of the game tecnically increases: more squares opened, fewer squares left, more probability of hitting the bomb
  fill(255);
  textSize(11);
  textAlign(LEFT, TOP);
  text("Find safe squares,\navoid the bomb!\nCash out anytime.", 23, height - 60);
}

void gameTab() {
  background(bgLight);
  rectMode(CORNERS);
  fill(bgDark);
  rect(0, 0, 200, height);
  
  fill(255);
  textSize(17);
  textAlign(LEFT, CENTER);
  text("Bet Amount", 23, 25);
  text("$" + betAmount, 30, 50);
  text("Opened", 23, 85);
  text(opened + "/" + (gridSize * gridSize - 1), 30, 110);
  text("Potential Win", 23, 145);
  text("$" + potentialWin, 30, 170);
  
  // Cash Out button
  fill(buttonIn);
  rectMode(CENTER);
  rect(100, 220, 160, 40, 10);
  fill(bgDark);
  textAlign(CENTER, CENTER);
  text("Cash Out", 100, 220);
}

void gameOverTab() {
  background(bgLight);
  rectMode(CORNERS);
  fill(bgDark);
  rect(0, 0, 200, height);
  
  fill(255);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("BOOM!", 100, 80);
  
  textSize(17);
  text("You hit a mine!", 100, 120);
  text("You lost $" + betAmount, 100, 150);
  
  // Continue button
  fill(buttonIn);
  rectMode(CENTER);
  rect(100, 220, 160, 40, 10);
  fill(bgDark);
  text("Continue", 100, 220);
}

void drawGrid() {
  squareSize = min((width - 200), height) / gridSize - gap;
  
  rectMode(CENTER);
  
  // Positioning the first square of the grid based on the screen size and grid size
  if (gridSize % 2 == 1) {
    squareX0 = (200 + ((width - 200) / 2)) - ((squareSize + gap) * (gridSize / 2));
    squareY = (height / 2) - ((squareSize + gap) * (gridSize / 2));
  } else {
    squareX0 = (200 + ((width - 200) / 2)) - ((squareSize + gap) / 2) - (squareSize + gap);
    squareY = (height / 2) - ((squareSize + gap) / 2) - (squareSize + gap);
  }
  
  int index = 0;
  int tempY = squareY;
  for (int i = 0; i < gridSize; i++) {
    int tempX = squareX0;
    for (int j = 0; j < gridSize; j++) {
      if (gameState == 0) {
        fill(buttonOut); // this counts as adding loop to add color to the background
        rect(tempX, tempY + 7, squareSize, squareSize, 10);
        fill(buttonIn);
        rect(tempX, tempY, squareSize, squareSize, 10);
      } else if ((gameState == 1 || gameState == 2) && index < squares.size()) {
        fill(buttonOut);
        rect(squares.get(index).x, squares.get(index).y + 7, squareSize, squareSize, 10);
        squares.get(index).display();
      }
      tempX += squareSize + gap;
      index++;
    }
    tempY += squareSize + gap;
  }
}

void initGame() {
  squares.clear();
  opened = 0;
  bombIndex = int(random(gridSize * gridSize));
  potentialWin = betAmount;
  
  squareSize = min((width - 200), height) / gridSize - gap;
  
  if (gridSize % 2 == 1) {
    squareX0 = (200 + ((width - 200) / 2)) - ((squareSize + gap) * (gridSize / 2));
    squareY = (height / 2) - ((squareSize + gap) * (gridSize / 2));
  } else {
    squareX0 = (200 + ((width - 200) / 2)) - ((squareSize + gap) / 2) - (squareSize + gap);
    squareY = (height / 2) - ((squareSize + gap) / 2) - (squareSize + gap);
  }
  
  int index = 0;
  int tempY = squareY;
  for (int i = 0; i < gridSize; i++) {
    int tempX = squareX0;
    for (int j = 0; j < gridSize; j++) {
      boolean isBomb = (index == bombIndex);
      squares.add(new Square(tempX, tempY, squareSize, index, isBomb));
      tempX += squareSize + gap;
      index++;
    }
    tempY += squareSize + gap;
  }
}

void buttonInteraction() {
  if (gameState == 0) {
    // Grid size buttons
    if (abs(48 - mouseX) <= 25 && abs(140 - mouseY) <= 17) {
      gridSize = 3;
    }
    if (abs(100 - mouseX) <= 25 && abs(140 - mouseY) <= 17) {
      gridSize = 4;
    }
    if (abs(152 - mouseX) <= 25 && abs(140 - mouseY) <= 17) {
      gridSize = 5;
    }
    
    // Bet amount buttons
    if (abs(48 - mouseX) <= 25 && abs(220 - mouseY) <= 17) {
      betAmount = min(100, totalAmount);
    }
    if (abs(100 - mouseX) <= 25 && abs(220 - mouseY) <= 17) {
      betAmount = min(300, totalAmount);
    }
    if (abs(152 - mouseX) <= 25 && abs(220 - mouseY) <= 17) {
      betAmount = totalAmount;
    }
    
    // Bet button: check if user has enough money
    if (abs(100 - mouseX) <= 80 && abs(280 - mouseY) <= 20) {
      if (betAmount > 0 && betAmount <= totalAmount) {
        totalAmount -= betAmount;
        initGame();
        gameState = 1;
      }
    }
    
    // Exit button
    if (abs(100 - mouseX) <= 40 && abs(320 - mouseY) <= 10) {
      exit();
    }
  } else if (gameState == 1) {
    // Cash out button
    if (abs(100 - mouseX) <= 80 && abs(220 - mouseY) <= 20) {
      totalAmount += potentialWin;
      gameState = 0;
      return;
    }

    if (mouseX > 200) {  // Only click squares if mouse is in grid area
      for (Square s : squares) {
        if (!s.opened && s.isClicked(mouseX, mouseY)) {
          s.opened = true;
          if (s.isBomb) {
            // Game over: reveal all bombs and show for a moment
            for (Square sq : squares) {
              sq.opened = true;
            }
            potentialWin = 0;
            gameState = 2;
          } else {
            opened++;
            // Probability of surviving = (totalSquares - opened) / (totalSquares - opened + 1)/ Multiplier is the inverse of cumulative survival probability
            totalSquares = gridSize * gridSize - 1; // minus the bomb
            multiplier = totalSquares / (totalSquares - opened);
            potentialWin = int(betAmount * multiplier);
            
            // Check if won (all safe squares opened)
            if (opened >= gridSize * gridSize - 1) {
              totalAmount += potentialWin;
              gameState = 0;
            }
          }
          break;
        }
      }
    }
  } else if (gameState == 2) {
    // Continue button on game over screen
    if (abs(100 - mouseX) <= 80 && abs(220 - mouseY) <= 20) {
      gameState = 0;
    }
  }
}

void mouseClicked() {
  buttonInteraction();
}

void draw() {
  if (gameState == 0) {
    tab();
    drawGrid();
  } else if (gameState == 1) {
    gameTab();
    drawGrid();
  } else if (gameState == 2) {
    gameOverTab();
    drawGrid();
  }
}
// There might be like a second delay between the clicks 
// I think the game can be optimized with if statements before huge methods,
// like in line 298
