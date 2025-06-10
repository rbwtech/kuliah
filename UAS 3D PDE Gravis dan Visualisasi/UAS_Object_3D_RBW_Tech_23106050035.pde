/*
 * RBW-Tech 3D Interactive Object
 * ==============================
 * Author: Radipta Basri Wijaya (23106050035)
 * Course: Processing (UAS Assignment)
 * 
 * Description:
 * Interactive 3D text object displaying "RBW-Tech" with complete
 * transformation controls, lighting system, and real-time interaction.
 * 
 * Features:
 * - 6DOF transformations (Pitch, Yaw, Roll, Crab, Ped, Zoom)
 * - Mouse-based drag controls
 * - Dynamic lighting with ray tracing effects
 * - Real-time texture toggle
 * - Interactive UI panel
 */

// ============================
// CORE TRANSFORMATION SYSTEM
// ============================
float pitch = 0, yaw = 0, roll = 0;        // Rotation angles (degrees)
float crabX = 100, pedY = 0;               // Translation coordinates
float zoomLevel = 1.0;                     // Scale factor

// ============================
// FEATURE TOGGLES
// ============================
boolean textureOn = true;                  // Wireframe overlay state
boolean shadowOn = true;                   // Lighting system state

// ============================
// INPUT CONTROL SYSTEM
// ============================
// Keyboard state tracking
boolean[] keys = new boolean[256];         // Regular key states
boolean[] specialKeys = new boolean[4];    // Arrow key states [UP, DOWN, LEFT, RIGHT]

// Mouse interaction state
float pmouseX_3d, pmouseY_3d;             // Previous mouse coordinates
boolean isDragging = false;                // Drag operation flag
int dragMode = 0;                          // 0=none, 1=translate, 2=rotate
boolean middlePressed = false;             // Middle mouse button state

// ============================
// LIGHTING SYSTEM
// ============================
float lightX = 100, lightY = -100, lightZ = 100;    // Light source position

// ============================
// CAMERA SYSTEM
// ============================
float camX = 0, camY = 0, camZ = 350;     // Camera position

// ============================
// MOTION PARAMETERS
// ============================
float rotSpeed = 2.0;                     // Rotation speed (degrees/frame)
float moveSpeed = 3.0;                    // Translation speed (pixels/frame)
float zoomSpeed = 0.02;                   // Zoom speed (scale/frame)
float mouseSensitivity = 0.5;             // Mouse drag sensitivity

// ============================
// VISUAL THEME
// ============================
color[] gradientColors = {
  color(255, 80, 120),   // R - Pink-red
  color(120, 80, 255),   // B - Purple-blue
  color(80, 200, 255),   // W - Light blue
  color(255, 200, 80),   // - - Orange
  color(80, 255, 120),   // T - Green
  color(120, 255, 80),   // e - Light green
  color(80, 255, 200),   // c - Cyan
  color(200, 255, 80)    // h - Yellow-green
};

// ============================
// INITIALIZATION
// ============================
void setup() {
  size(1200, 750, P3D);
  
  printControlGuide();
}

void printControlGuide() {
  println("=== RBW-TECH 3D CONTROLS ===");
  println("KEYBOARD:");
  println("  WASD: Pitch/Yaw rotation");
  println("  Q/E: Roll rotation");
  println("  Arrow Keys: Crab/Ped translation");
  println("  Z/X: Zoom in/out");
  println("  T: Toggle texture wireframe");
  println("  L: Toggle lighting system");
  println("  R: Reset all transformations");
  println("");
  println("MOUSE:");
  println("  Left Drag: Move object");
  println("  Right Drag: Rotate object");
  println("  Wheel: Zoom control");
  println("  Middle + Move: Roll control");
  println("  Move: Light source positioning");
}

// ============================
// MAIN RENDER LOOP
// ============================
void draw() {
  background(245, 248, 252);
  
  // Process all user inputs
  processKeyboardInput();
  processMouseInput();
  
  // Configure lighting system
  setupLightingSystem();
  
  // Position camera
  camera(camX, camY, camZ, 0, 0, 0, 0, 1, 0);
  
  // Render 3D scene
  render3DScene();
  
  // Render user interface
  renderUI();
}

// ============================
// INPUT PROCESSING
// ============================
void processKeyboardInput() {
  // Rotation controls (WASD + QE)
  if (keys['w'] || keys['W']) pitch -= rotSpeed;  // Pitch down
  if (keys['s'] || keys['S']) pitch += rotSpeed;  // Pitch up
  if (keys['a'] || keys['A']) yaw -= rotSpeed;    // Yaw left
  if (keys['d'] || keys['D']) yaw += rotSpeed;    // Yaw right
  if (keys['q'] || keys['Q']) roll -= rotSpeed;   // Roll left
  if (keys['e'] || keys['E']) roll += rotSpeed;   // Roll right
  
  // Zoom controls (ZX)
  if (keys['z'] || keys['Z']) zoomLevel += zoomSpeed;                    // Zoom in
  if (keys['x'] || keys['X']) zoomLevel = max(0.1, zoomLevel - zoomSpeed); // Zoom out
  
  // Translation controls (Arrow Keys)
  if (specialKeys[0]) pedY -= moveSpeed;    // Up
  if (specialKeys[1]) pedY += moveSpeed;    // Down
  if (specialKeys[2]) crabX -= moveSpeed;   // Left
  if (specialKeys[3]) crabX += moveSpeed;   // Right
}

void processMouseInput() {
  // Handle drag operations
  if (mousePressed && isDragging && !middlePressed) {
    float deltaX = mouseX - pmouseX_3d;
    float deltaY = mouseY - pmouseY_3d;
    
    switch(dragMode) {
      case 1: // Left click - Translation
        crabX += deltaX * mouseSensitivity;
        pedY += deltaY * mouseSensitivity;
        break;
        
      case 2: // Right click - Rotation
        yaw += deltaX * mouseSensitivity;
        pitch += deltaY * mouseSensitivity;
        break;
    }
  }
  
  // Handle middle mouse roll control
  if (middlePressed && mousePressed) {
    float deltaY = mouseY - pmouseY_3d;
    if (abs(deltaY) > 1) {
      if (deltaY < 0) {
        roll += 2; // Mouse up = Roll right
      } else {
        roll -= 2; // Mouse down = Roll left
      }
    }
  }
  
  // Update mouse position tracking
  pmouseX_3d = mouseX;
  pmouseY_3d = mouseY;
}

// ============================
// LIGHTING SYSTEM
// ============================
void setupLightingSystem() {
  if (shadowOn) {
    // Multi-light setup for realistic rendering
    ambientLight(60, 65, 75);                                            // Base illumination
    directionalLight(255, 240, 220, lightX/200, lightY/200, lightZ/200); // Main directional light
    pointLight(255, 200, 150, lightX, lightY, lightZ);                   // Primary point light
    pointLight(100, 150, 255, -lightX*0.3, lightY*0.5, lightZ*0.8);     // Secondary fill light
  } else {
    ambientLight(180, 180, 180); // Flat lighting
  }
}

void renderLightSource() {
  pushMatrix();
  translate(lightX, lightY, lightZ);
  
  // Multi-layer glow effect
  fill(255, 255, 100, 60);  noStroke(); sphere(25); // Outer glow
  fill(255, 255, 150, 120);             sphere(18); // Middle glow
  fill(255, 255, 200, 200);             sphere(12); // Inner core
  fill(255, 255, 255);                  sphere(6);  // Bright center
  
  stroke(1);
  popMatrix();
}

// ============================
// 3D SCENE RENDERING
// ============================
void render3DScene() {
  pushMatrix();
  
  // Apply all transformations
  scale(zoomLevel);                    // Zoom
  translate(crabX, pedY, 0);          // Translation
  rotateX(radians(pitch));            // Pitch rotation
  rotateY(radians(yaw));              // Yaw rotation
  rotateZ(radians(roll));             // Roll rotation
  
  // Render main object
  renderRBWTechText();
  
  popMatrix();
  
  // Render light source indicator
  if (shadowOn) {
    renderLightSource();
  }
}

void renderRBWTechText() {
  float letterSpacing = 45;  // Spacing for "RBW"
  float techSpacing = 35;    // Spacing for "Tech"
  
  // Apply texture effect
  if (textureOn) {
    stroke(255, 100);
    strokeWeight(0.5);
  } else {
    noStroke();
  }
  
  // Render "RBW-" section
  renderLetter(-3.5 * letterSpacing, gradientColors[0], 'R');
  renderLetter(-2.3 * letterSpacing, gradientColors[1], 'B');
  renderLetter(-1.1 * letterSpacing, gradientColors[2], 'W');
  renderLetter( 0.1 * letterSpacing, gradientColors[3], '-');
    
  // Render "Tech" section
  float techStartX = letterSpacing * 0.8;
  renderLetter(techStartX + 0*techSpacing, gradientColors[4], 'T');
  renderLetter(techStartX + 1*techSpacing, gradientColors[5], 'e');
  renderLetter(techStartX + 2*techSpacing, gradientColors[6], 'c');
  renderLetter(techStartX + 3*techSpacing, gradientColors[7], 'h');
}

void renderLetter(float x, color letterColor, char letter) {
  pushMatrix();
  translate(x, 0, 0);
  fill(letterColor);
  
  switch(letter) {
    case 'R': drawLetterR(); break;
    case 'B': drawLetterB(); break;
    case 'W': drawLetterW(); break;
    case '-': drawHyphen(); break;
    case 'T': drawLetterT(); break;
    case 'e': drawLetterE(); break;
    case 'c': drawLetterC(); break;
    case 'h': drawLetterH(); break;
  }
  
  popMatrix();
}

// ============================
// LETTER GEOMETRY DEFINITIONS
// ============================
void drawLetterR() {
  // Vertical spine
  pushMatrix(); translate(-12, 0, 0); box(6, 50, 15); popMatrix();
  
  // Horizontal segments
  pushMatrix(); translate(0, -20, 0); box(20, 6, 15); popMatrix(); // Top
  pushMatrix(); translate(-2, -2, 0); box(16, 6, 15); popMatrix();  // Middle
  
  // Right vertical segment
  pushMatrix(); translate(12, -11, 0); box(6, 18, 15); popMatrix();
  
  // Diagonal leg
  pushMatrix(); translate(8, 12, 0); rotateZ(radians(35)); box(20, 6, 15); popMatrix();
}

void drawLetterB() {
  // Vertical spine
  pushMatrix(); translate(-12, 0, 0); box(6, 50, 15); popMatrix();
  
  // Horizontal segments
  pushMatrix(); translate(-2, -20, 0); box(18, 6, 15); popMatrix(); // Top
  pushMatrix(); translate(-2, -2, 0); box(18, 6, 15); popMatrix();  // Middle
  pushMatrix(); translate(-2, 20, 0); box(18, 6, 15); popMatrix();  // Bottom
  
  // Right vertical segments
  pushMatrix(); translate(10, -11, 0); box(6, 18, 15); popMatrix();  // Top
  pushMatrix(); translate(10, 9, 0); box(6, 22, 15); popMatrix();    // Bottom
}

void drawLetterW() {
  // Outer verticals
  pushMatrix(); translate(-15, 0, 0); box(6, 50, 15); popMatrix();   // Left
  pushMatrix(); translate(15, 0, 0); box(6, 50, 15); popMatrix();    // Right
  
  // Inner diagonals
  pushMatrix(); translate(-5, 10, 0); rotateZ(radians(-15)); box(6, 25, 15); popMatrix(); // Left
  pushMatrix(); translate(5, 10, 0); rotateZ(radians(15)); box(6, 25, 15); popMatrix();   // Right
}

void drawHyphen() {
  pushMatrix(); translate(0, 0, 0); box(20, 6, 15); popMatrix();
}

void drawLetterT() {
  // Horizontal top
  pushMatrix(); translate(0, -20, 0); box(30, 6, 15); popMatrix();
  
  // Vertical center
  pushMatrix(); translate(0, 3, 0); box(6, 34, 15); popMatrix();
}

void drawLetterE() {
  // Vertical spine
  pushMatrix(); translate(-8, 0, 0); box(5, 35, 12); popMatrix();
  
  // Horizontal segments
  pushMatrix(); translate(2, -15, 0); box(15, 5, 12); popMatrix();   // Top
  pushMatrix(); translate(0, 0, 0); box(12, 5, 12); popMatrix();     // Middle
  pushMatrix(); translate(2, 15, 0); box(15, 5, 12); popMatrix();    // Bottom
}

void drawLetterC() {
  // Vertical spine
  pushMatrix(); translate(-8, 0, 0); box(5, 30, 12); popMatrix();
  
  // Horizontal segments
  pushMatrix(); translate(1, -12, 0); box(13, 5, 12); popMatrix();   // Top
  pushMatrix(); translate(1, 12, 0); box(13, 5, 12); popMatrix();    // Bottom
}

void drawLetterH() {
  // Vertical spines
  pushMatrix(); translate(-6, 0, 0); box(5, 35, 12); popMatrix();    // Left
  pushMatrix(); translate(6, 0, 0); box(5, 35, 12); popMatrix();     // Right
  
  // Horizontal crossbar
  pushMatrix(); translate(0, 0, 0); box(15, 5, 12); popMatrix();
}

// ============================
// USER INTERFACE SYSTEM
// ============================
void renderUI() {
  // Switch to 2D rendering mode
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  
  renderControlPanel();
  
  hint(ENABLE_DEPTH_TEST);
}

void renderControlPanel() {
  // Main panel background
  fill(255, 255, 255, 250);
  stroke(120, 120, 120);
  strokeWeight(2);
  rect(15, 50, 380, 360, 8);
  
  // Header section
  fill(50, 100, 180, 220);
  noStroke();
  rect(15, 50, 380, 35, 8, 8, 0, 0);
  
  // Panel title
  fill(255, 255, 255);
  textSize(14);
  textAlign(LEFT);
  text("RBW-Tech 3D Control Panel", 25, 72);
  
  // Content sections
  renderControlSections();
  renderStatusDisplay();
  renderToggleButtons();
}

void renderControlSections() {
  fill(20, 20, 20);
  textSize(11);
  
  float lineHeight = 17.5;
  int startY = 100;
  
  // Keyboard controls section
  text("=== KEYBOARD CONTROLS ===", 25, startY);
  text("WASD: Pitch/Yaw (smooth rotation)", 25, startY + lineHeight);
  text("Q/E: Roll (smooth rotation)", 25, startY + 2*lineHeight);
  text("Arrow Keys: Crab/Ped (smooth translation)", 25, startY + 3*lineHeight);
  text("Z/X: Zoom in/out (smooth)", 25, startY + 4*lineHeight);
  text("R: Reset all positions", 25, startY + 5*lineHeight);
  
  // Mouse controls section
  text("=== MOUSE CONTROLS ===", 25, startY + 7*lineHeight);
  text("LEFT CLICK + DRAG: Move object around", 25, startY + 8*lineHeight);
  text("RIGHT CLICK + DRAG: Rotate 3D object", 25, startY + 9*lineHeight);
  text("MOUSE WHEEL: Zoom in/out", 25, startY + 10*lineHeight);
  text("MIDDLE CLICK + WHEEL: Roll left/right", 25, startY + 11*lineHeight);
  text("MOUSE MOVE: Move light source", 25, startY + 12*lineHeight);
}

void renderStatusDisplay() {
  fill(20, 20, 20);
  textSize(11);
  
  float lineHeight = 17.5;
  int startY = 100;
  
  // Status section
  text("=== CURRENT STATUS ===", 25, startY + 14*lineHeight);
  text("Pitch: " + nf(pitch, 0, 1) + "°", 25, startY + 15*lineHeight);
  text("Yaw: " + nf(yaw, 0, 1) + "°", 200, startY + 15*lineHeight);
  text("Roll: " + nf(roll, 0, 1) + "°", 25, startY + 16*lineHeight);
  text("Zoom: " + nf(zoomLevel, 0, 2) + "x", 200, startY + 16*lineHeight);
  text("Crab: " + nf(crabX, 0, 1), 25, startY + 17*lineHeight);
  text("Ped: " + nf(pedY, 0, 1), 200, startY + 17*lineHeight);
}

void renderToggleButtons() {
  float lineHeight = 17.5;
  int startY = 100;
  
  renderButton(25, startY + 18*lineHeight, 150, 25, "Toggle Texture (T)", textureOn, color(30, 120, 255));
  renderButton(200, startY + 18*lineHeight, 180, 25, "Toggle Lighting/Shadow (L)", shadowOn, color(255, 120, 30));
}

void renderButton(float x, float y, float w, float h, String label, boolean active, color baseColor) {
  // Button background
  if (active) {
    fill(red(baseColor), green(baseColor), blue(baseColor), 220);
    noStroke();
  } else {
    fill(220, 220, 220, 255);
    stroke(180, 180, 180);
    strokeWeight(1);
  }
  
  rect(x, y, w, h, 6);
  
  // Button text
  fill(active ? color(255, 255, 255) : color(80, 80, 80));
  textAlign(CENTER, CENTER);
  textSize(11);
  text(label, x + w/2, y + h/2);
}

// ============================
// EVENT HANDLERS
// ============================
void keyPressed() {
  // Special keys (arrows)
  if (keyCode == UP) specialKeys[0] = true;
  if (keyCode == DOWN) specialKeys[1] = true;
  if (keyCode == LEFT) specialKeys[2] = true;
  if (keyCode == RIGHT) specialKeys[3] = true;
  
  // Regular keys
  if (key >= 0 && key < keys.length) {
    keys[key] = true;
  }
  
  // Instant toggle functions
  if (key == 't' || key == 'T') textureOn = !textureOn;
  if (key == 'l' || key == 'L') shadowOn = !shadowOn;
  
  // Reset function
  if (key == 'r' || key == 'R') {
    resetAllTransformations();
  }
}

void keyReleased() {
  // Special keys
  if (keyCode == UP) specialKeys[0] = false;
  if (keyCode == DOWN) specialKeys[1] = false;
  if (keyCode == LEFT) specialKeys[2] = false;
  if (keyCode == RIGHT) specialKeys[3] = false;
  
  // Regular keys
  if (key >= 0 && key < keys.length) {
    keys[key] = false;
  }
}

void mousePressed() {
  // Middle mouse button for roll control
  if (mouseButton == CENTER) {
    middlePressed = true;
    pmouseX_3d = mouseX;
    pmouseY_3d = mouseY;
    return;
  }
  
  // Check UI button clicks
  if (handleUIButtonClicks()) return;
  
  // Initialize drag operation
  isDragging = true;
  pmouseX_3d = mouseX;
  pmouseY_3d = mouseY;
  
  // Set drag mode
  if (mouseButton == LEFT) dragMode = 1;      // Translation
  else if (mouseButton == RIGHT) dragMode = 2; // Rotation
}

boolean handleUIButtonClicks() {
  float buttonY = 100 + 18*17.5;
  
  // Texture button
  if (mouseX >= 25 && mouseX <= 175 && mouseY >= buttonY && mouseY <= buttonY + 25) {
    textureOn = !textureOn;
    return true;
  }
  
  // Lighting button
  if (mouseX >= 200 && mouseX <= 380 && mouseY >= buttonY && mouseY <= buttonY + 25) {
    shadowOn = !shadowOn;
    return true;
  }
  
  return false;
}

void mouseReleased() {
  isDragging = false;
  dragMode = 0;
  middlePressed = false;
}

void mouseWheel(MouseEvent event) {
  float wheelDirection = event.getCount();
  
  // Zoom control
  if (wheelDirection < 0) {
    zoomLevel += 0.1; // Zoom in
  } else {
    zoomLevel = max(0.1, zoomLevel - 0.1); // Zoom out
  }
}

void mouseMoved() {
  // Light source positioning (when not dragging)
  if (!isDragging && !middlePressed) {
    lightX = map(mouseX, 0, width, -300, 300);
    lightY = map(mouseY, 0, height, -200, 200);
  }
}

// ============================
// UTILITY FUNCTIONS
// ============================
void resetAllTransformations() {
  pitch = yaw = roll = 0;
  crabX = pedY = 0;
  zoomLevel = 1.0;
  lightX = 100; 
  lightY = -100; 
  lightZ = 100;
}
