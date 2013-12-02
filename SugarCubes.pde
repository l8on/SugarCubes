/**
 *           +-+-+-+-+-+               +-+-+-+-+-+
 *          /         /|               |\         \
 *         /         / +               + \         \
 *        +-+-+-+-+-+  |   +-+-+-+-+   |  +-+-+-+-+-+
 *        |         |  +  /         \  +  |         |
 *        +   THE   + /  /           \  \ +  CUBES  +
 *        |         |/  +-+-+-+-+-+-+-+  \|         |
 *        +-+-+-+-+-+   |             |   +-+-+-+-+-+
 *                      +             +
 *                      |    SUGAR    |
 *                      +             +
 *                      |             |
 *                      +-+-+-+-+-+-+-+
 *
 * Welcome to the Sugar Cubes! This Processing sketch is a fun place to build
 * animations, effects, and interactions for the platform. Most of the icky
 * code guts are embedded in the GLucose library extension. If you're an
 * artist, you shouldn't need to worry about any of that.
 *
 * Below, you will find definitions of the Patterns, Effects, and Interactions.
 * If you're an artist, create a new tab in the Processing environment with
 * your name. Implement your classes there, and add them to the list below.
 */ 

LXPattern[] patterns(GLucose glucose) {
  return new LXPattern[] {

    new SineSphere(glucose),
    //new CubeCurl(glucose), 
     
    // Slee
    // new Cathedrals(glucose),
     new Swarm(glucose),
    new MidiMusic(glucose),
    new Pulley(glucose),
    
    new ViolinWave(glucose),
    new BouncyBalls(glucose),
    new SpaceTime(glucose),
    new ShiftingPlane(glucose),
    new AskewPlanes(glucose),
    new Blinders(glucose),
    new CrossSections(glucose),
    new Psychedelia(glucose),

    new MultipleCubes(glucose),
    
    new Traktor(glucose).setEligible(false),
    new BassPod(glucose).setEligible(false),
    new CubeEQ(glucose).setEligible(false),
    new PianoKeyPattern(glucose).setEligible(false),

	// AntonK
	new AKPong(glucose),

    // DanH
    new Noise(glucose),
    new Play (glucose),
    new Pong (glucose),
    new Worms(glucose),

    // JR
    new Gimbal(glucose),
    
    // Alex G
     
     // Tim
    new TimMetronome(glucose),
    new TimPlanes(glucose),
    new TimPinwheels(glucose),
    new TimRaindrops(glucose),
    new TimCubes(glucose),
    // new TimTrace(glucose),
    new TimSpheres(glucose),

    // Jackie
    new JackieSquares(glucose),
    new JackieLines(glucose),
    new JackieDots(glucose),

    // L8on
    new L8onAutomata(glucose),
    new L8onLife(glucose),
    new L8onStripLife(glucose),
    new L8onBreathe(glucose),
    new L8onBreatheSlant(glucose),

    // Vincent
    new VSTowers(glucose),
    
    // Toby
    new GlitchPlasma(glucose),
    new FireEffect(glucose).setEligible(false),
    new StripBounce(glucose),
    new SoundRain(glucose).setEligible(false),
    new SoundSpikes(glucose).setEligible(false),
    new FaceSync(glucose),

    // Jack
    new Swim(glucose),
    new Balance(glucose),
    

    
    // Ben
    // new Sandbox(glucose),
    new TowerParams(glucose),
    new DriveableCrossSections(glucose),
    new GranimTestPattern2(glucose),
    
    // Shaheen
    //new HelixPattern(glucose).setEligible(false),
    
    // Sam
    new JazzRainbow(glucose),
    
    // Arjun
    new TelevisionStatic(glucose),
    new AbstractPainting(glucose),
    new Spirality(glucose),

    // Basic test patterns for reference, not art    
    new TestCubePattern(glucose),
    new TestTowerPattern(glucose),
    new TestProjectionPattern(glucose),
    new TestStripPattern(glucose),
    new TestBassMapping(glucose),
    new TestFloorMapping(glucose),
    new TestSpeakerMapping(glucose),    
    // new TestHuePattern(glucose),
    // new TestXPattern(glucose),
    // new TestYPattern(glucose),
    // new TestZPattern(glucose),

  };
}

LXTransition[] transitions(GLucose glucose) {
  return new LXTransition[] {
    new DissolveTransition(lx),
    new AddTransition(glucose),
    new MultiplyTransition(glucose),
    new OverlayTransition(glucose),
    new DodgeTransition(glucose),
    new SwipeTransition(glucose),
    new FadeTransition(lx),
//  new SubtractTransition(glucose),	// similar to multiply - dh
//  new BurnTransition(glucose),		// similar to multiply - dh
//  new ScreenTransition(glucose), 		// same as add -dh
//  new SoftLightTransition(glucose),	// same as overlay -dh
  };
}

// Handles to globally triggerable effects 
class Effects {
  FlashEffect flash = new FlashEffect(lx);
  BoomEffect boom = new BoomEffect(glucose);
  BlurEffect blur = new BlurEffect(glucose);
  QuantizeEffect quantize = new QuantizeEffect(glucose);
  ColorFuckerEffect colorFucker = new ColorFuckerEffect(glucose);
  
  Effects() {
    blur.enable();
    quantize.enable();
    colorFucker.enable();
  }
}

