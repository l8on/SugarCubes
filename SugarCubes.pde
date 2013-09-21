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
    
    // Slee
    new Swarm(glucose),
    new SpaceTime(glucose),
    new ShiftingPlane(glucose),
    new AskewPlanes(glucose),
    new Blinders(glucose),
    new CrossSections(glucose),
    new Psychedelia(glucose),
    
    new Traktor(glucose).setEligible(false),
    new BassPod(glucose).setEligible(false),
    new CubeEQ(glucose).setEligible(false),
    new PianoKeyPattern(glucose).setEligible(false),

    // DanH
    new Noise(glucose),
    new Play(glucose),
    new Pong(glucose),

    // Alex G
    new SineSphere(glucose),

    
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

    // Tim
    new TimPlanes(glucose),
   // new TimPinwheels(glucose),
    new TimRaindrops(glucose),
    new TimCubes(glucose),
    // new TimTrace(glucose),
    //new TimSpheres(glucose),

    // Ben
    // new Sandbox(glucose),
    new TowerParams(glucose),
    new DriveableCrossSections(glucose),
    new GranimTestPattern2(glucose),
    
  
    // Sam
  
    
    // Arjun
    new TelevisionStatic(glucose),
  //  new AbstractPainting(glucose),
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
    new MultiplyTransition(glucose),
    new ScreenTransition(glucose),
    new BurnTransition(glucose),
    new DodgeTransition(glucose),
    new OverlayTransition(glucose),
    new AddTransition(glucose),
    new SubtractTransition(glucose),
    new SoftLightTransition(glucose),
    new SwipeTransition(glucose),
    new FadeTransition(lx),
  };
}

LXEffect[] effects(GLucose glucose) {
  return new LXEffect[] {
    new FlashEffect(lx),
    new BoomEffect(glucose),
    new BlurEffect(glucose),
    new DesaturationEffect(lx),
    new ColorFuckerEffect(glucose),
  };
}
