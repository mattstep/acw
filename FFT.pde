class FFTDemo extends Routine {
  FFT fft;
  Minim minim;
  AudioInput audioin;

  void setup(PApplet parent) {
    super.setup(parent);
    minim = new Minim(parent);
    audioin = minim.getLineIn(Minim.STEREO, 2048);
    fft = new FFT(audioin.bufferSize(), audioin.sampleRate());
  }

  void draw() {
    long frame = frameCount - modeFrameStart;

    background(0);
    stroke(255);

    fft.forward(audioin.mix);

    for (int i = 0; i < fft.specSize(); i++)
    {
      // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
      //    stroke(0,0,255);
      //    line(i, HEIGHT, i, HEIGHT - fft.getBand(i)*4);
      //    //line(i, HEIGHT, i, HEIGHT - fft.getBand(i));
      float barHeight = fft.getBand(i)*4;
      for (float c = 0; c < barHeight; c++) {
        if (isRGB) {
          stroke(c/barHeight*255, 0, 255);
        }
        else {
          stroke(255-(c/barHeight*255));
        }
        point(i, HEIGHT - c);
      }
    }

    if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
      newMode();
    }
  }
}

