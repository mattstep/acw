import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import codeanticode.gsvideo.*;
import processing.opengl.*;
import java.lang.reflect.Method;
import hypermedia.net.*;
import java.io.*;

/*
// Disorient ACW settings
int WIDTH = 16;
int HEIGHT = 16;
int addressing = Sculpture.ADDRESSING_VERTICAL_FLIPFLOP;
*/

// Want It! matrix display settings
int WIDTH = 25;
int HEIGHT = 12;
int addressing = Sculpture.ADDRESSING_HORIZONTAL_NORMAL;
int FRAMERATE = 30;

String[] hostnames = new String[] {
  "127.0.0.1", // when using the emulator
  //"192.168.1.130", // disorient on playa
  "192.168.1.78", // want it! on playa
};
int TYPICAL_MODE_TIME = 300;

Routine[] enabledRoutines = new Routine[] {
  new Greetz(new String[] { "ART CAR WASH" }),
  //new Bursts(),
  new FlashColors(),      /* rainbow */
  //new Flash(),            /* seizure mode */
  //new Lines(),            /* boring */
  //new OppositeLines(),    /* boring */
  //new Waves(),            /* ? */
  //new HorizonScan(),
  //new RadialStars(),
  //new NightSky(),
  //new TargetScanner(),
  //new Warp(new Waterfalls(), true, false, 0.5, 0.25)
  //new RGBRoutine(),
  //new FFTDemo(),
  //new FollowMouse(),
  //new Warp(new Greetz(new String[] { "COUNTRY CLUB", "D12ORIENT" }), false, true, 1, 0.25)
  //new Warp(null, true, true, 0.5, 0.25)
};

int w = 0;
int x = WIDTH;
PFont font;
int ZOOM = 1;

long modeFrameStart;
int mode = 0;

int direction = 1;
int position = 0;
Routine currentRoutine = null;

Sculpture dacwes;

PGraphics fadeLayer;
int fadeOutFrames = 0;
int fadeInFrames = 0;

WiiController controller;
boolean isRGB = true;

void setup() {
  // Had to enable OPENGL for some reason new fonts don't work in JAVA2D.
  size(WIDTH,HEIGHT);

  frameRate(FRAMERATE);

  dacwes = new Sculpture(this, WIDTH, HEIGHT, isRGB);
  dacwes.setAddress(hostnames[0]);
  dacwes.setAddressingMode(addressing);

  setMode(0);

  controller = new WiiController();

  for (Routine r : enabledRoutines) {
    r.setup(this);
  }
}

void setFadeLayer(int g) {
  fadeLayer = createGraphics(WIDTH, HEIGHT, P2D);
  fadeLayer.beginDraw();
  fadeLayer.stroke(g);
  fadeLayer.fill(g);
  fadeLayer.rect(0, 0, WIDTH, HEIGHT);
  fadeLayer.endDraw();
}

void setMode(int newMode) {
  //String methodName = enabledModes[newMode];
  currentRoutine = enabledRoutines[newMode];

  mode = newMode;
  modeFrameStart = frameCount;
  println("New mode " + currentRoutine.getClass().getName());

//  currentRoutine.reset();

}

void newMode() {
  int newMode = mode;
  String methodName;

  fadeOutFrames = FRAMERATE;
  setFadeLayer(240);
  if (enabledRoutines.length > 1) {
    while (newMode == mode) {
      newMode = int(random(enabledRoutines.length));
    }
  }

  setMode(newMode);
//  dacwes.sendMode(enabledModes[newMode]);
}

void draw() {
  if (fadeOutFrames > 0) {
    fadeOutFrames--;
    blend(fadeLayer, 0, 0, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT, MULTIPLY);

    if (fadeOutFrames == 0) {
      fadeInFrames = FRAMERATE;
    }
  }
  else if (currentRoutine != null) {
    currentRoutine.predraw();
    currentRoutine.draw();
  }
  else {
    println("Current method is null");
  }

  if (fadeInFrames > 0) {
    setFadeLayer(240 - fadeInFrames*8);
    blend(fadeLayer, 0, 0, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT, MULTIPLY);
    fadeInFrames--;
  }

  if (currentRoutine.isDone) {
    currentRoutine.isDone = false;
    newMode();
  }
//  println(frameRate);
  for (String hostname : hostnames) {
    dacwes.setAddress(hostname);
    dacwes.sendData();
  }
}


