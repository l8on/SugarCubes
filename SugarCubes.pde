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
    new ShiftingPlane(glucose),
    new AskewPlanes(glucose),
    new Swarm(glucose),
    new SpaceTime(glucose),
    new Blinders(glucose),
    new CrossSections(glucose),
    new Psychedelia(glucose),
    new CubeEQ(glucose),
    new PianoKeyPattern(glucose),
    new WarmPlasma(glucose),
    new FireTest(glucose),
    
    // Basic test patterns for reference, not art    
//    new TestCubePattern(glucose),
//    new TestHuePattern(glucose),
//    new TestXPattern(glucose),
//    new TestYPattern(glucose),
//    new TestZPattern(glucose),
//    new TestProjectionPattern(glucose),

  };
}

LXTransition[] transitions(GLucose glucose) {
  return new LXTransition[] {
    new DissolveTransition(lx),
    new SwipeTransition(glucose),
    new FadeTransition(lx),
  };
}

LXEffect[] effects(GLucose glucose) {
  return new LXEffect[] {
    new FlashEffect(lx),
    new BoomEffect(glucose),
    new DesaturationEffect(lx),
  };
}

