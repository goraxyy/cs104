import processing.core.PApplet;
import processing.core.PFont;

public class Story {
  private PFont gameFont;
  String[] stuff = {
    "Oh no, aliens are trying\n"
  + "to crush your home with boxes.",
  
    "The government gave you drones\n"
  + "to move blocks and clear them.",
  
    "Press any key to continue"
  };

  int current = 0;
  float y = 60;  // start lower so text is visible

  public Story(PFont gameFont) {
    this.gameFont = gameFont;
  } 

  public void display(PApplet applet) {
    applet.textFont(gameFont);
    applet.background(44, 0, 142);
    applet.rectMode(PApplet.CORNER);
    applet.fill(0);
    applet.rect(40, 40, 520, 520);
    applet.fill(255); 
    applet.textAlign(PApplet.CENTER);
    applet.textSize(19);

    if (current < 3) {
      applet.text(stuff[current], applet.width / 2, y);
      y += 1;


      if (y > applet.height + 10) {  // advance when text reaches middle
        if (current < 2) {
          current++;
          y = 60;  // reset y position for next message
        } else {
          current = 3;  // done with messages
        }
      }
    }

    if (current >= 3) {
      applet.text("Press any key to continue", applet.width / 2, applet.height / 2);
    }
  }
}
