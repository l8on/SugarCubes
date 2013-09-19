/**
 * This is a reusable equalizer class that lets you get averaged
 * bands with dB scaling and smoothing.
 */
public static class GraphicEQ {
  
  private final HeronLX lx;
  
  public final BasicParameter level = new BasicParameter("LVL", 0.5);
  public final BasicParameter range = new BasicParameter("RNGE", 0.5);
  public final BasicParameter slope = new BasicParameter("SLOP", 0.5);
  public final BasicParameter attack = new BasicParameter("ATK", 0.5);
  public final BasicParameter release = new BasicParameter("REL", 0.5);    

  private final FFT fft;
  private final int numBands;

  private final LinearEnvelope[] bandVals;
  
  public final static int DEFAULT_NUM_BANDS = 16;

  public GraphicEQ(HeronLX lx) {
    this(lx, DEFAULT_NUM_BANDS);
  }
  
  /**
   * Note that the number of bands is a suggestion. Due to the FFT implementation
   * the actual number may be slightly different.
   */
  public GraphicEQ(HeronLX lx, int num) {
    this.lx = lx;
    fft = new FFT(lx.audioInput().bufferSize(), lx.audioInput().sampleRate());
    fft.window(FFT.HAMMING);
    fft.logAverages(50, num/8);
    numBands = this.fft.avgSize();
    bandVals = new LinearEnvelope[numBands];
    for (int i = 0; i < bandVals.length; ++i) {
      (bandVals[i] = new LinearEnvelope(0, 0, 500)).trigger();
    }
  }
  
  final float logTen = log(10);
  public float log10(float val) {
    return log(val) / logTen;
  }
  
  public float getLevel(int band) {
    return bandVals[band].getValuef();
  }
  
  public float getAverageLevel(int minBand, int numBands) {
    float avg = 0;
    for (int i = minBand; i < minBand + numBands; ++i) {
      avg += bandVals[i].getValuef();
    }
    avg /= numBands;
    return avg;
  }
  
  public void run(double deltaMs) {
    fft.forward(lx.audioInput().mix);
    float zeroDBReference = pow(10, 100*(1-level.getValuef())/20.);
    float decibelRange = 12 + range.getValuef() * 60;
    float decibelSlope = slope.getValuef() * 60.f / numBands;
    for (int i = 0; i < numBands; ++i) {
      float raw = fft.getAvg(i);
      float decibels = 20*log10(raw / zeroDBReference);
      float positiveDecibels = decibels + decibelRange;
      positiveDecibels += i*decibelSlope;
      float value = constrain(positiveDecibels / decibelRange, 0, 1);
      
      if (value > bandVals[i].getValuef()) {
        bandVals[i].setEndVal(value, attack.getValuef() * 20).trigger();
      }
    }
    for (LinearEnvelope band : bandVals) {
      band.run(deltaMs);
      if (!band.isRunning() && band.getValuef() > 0) {
        band.setEndVal(0, release.getValuef() * 1600).trigger();
      }
    }    
  }
}


