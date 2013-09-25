/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * This file defines the MIDI mapping interfaces. This shouldn't
 * need editing unless you're adding top level support for a
 * specific MIDI device of some sort. Generally, all MIDI devices
 * will just work with the default configuration, and you can
 * set your SCPattern class to respond to the controllers that you
 * care about.
 */

interface MidiEngineListener {
  public void onFocusedDeck(int deckIndex);
}

class MidiEngine {

  private final List<MidiEngineListener> listeners = new ArrayList<MidiEngineListener>();
  private final List<SCMidiInput> midiControllers = new ArrayList<SCMidiInput>();

  public MidiEngine addListener(MidiEngineListener l) {
    listeners.add(l);
    return this;
  }

  public MidiEngine removeListener(MidiEngineListener l) {
    listeners.remove(l);
    return this;
  }

  private SCMidiInput midiQwertyKeys;
  private SCMidiInput midiQwertyAPC;

  private int activeDeckIndex = 0;

  public MidiEngine() {

    midiControllers.add(midiQwertyKeys = new SCMidiInput(SCMidiInput.KEYS));
    midiControllers.add(midiQwertyAPC = new SCMidiInput(SCMidiInput.APC));
    for (MidiInputDevice device : RWMidi.getInputDevices()) {
      if (device.getName().contains("APC")) {
        midiControllers.add(new APC40MidiInput(device).setEnabled(true));
      } else if (device.getName().contains("SLIDER/KNOB KORG")) {
        midiControllers.add(new KorgNanoKontrolMidiInput(device).setEnabled(true));
      } else {
        boolean enabled = device.getName().contains("KEYBOARD KORG");
        midiControllers.add(new SCMidiInput(device).setEnabled(enabled));
      }
    }
  }

  public List<SCMidiInput> getControllers() {
    return this.midiControllers;
  }

  public MidiEngine setFocusedDeck(int deckIndex) {
    if (this.activeDeckIndex != deckIndex) {
      this.activeDeckIndex = deckIndex;
      for (MidiEngineListener listener : listeners) {
        listener.onFocusedDeck(deckIndex);
      }
    }
    return this;
  }

  public Engine.Deck getFocusedDeck() {
    return lx.engine.getDeck(activeDeckIndex);
  }

  public boolean isQwertyEnabled() {
    return midiQwertyKeys.isEnabled() || midiQwertyAPC.isEnabled();
  }
}

public interface SCMidiInputListener {
  public void onEnabled(SCMidiInput controller, boolean enabled);
}

public class SCMidiInput extends AbstractScrollItem {

  public static final int MIDI = 0;
  public static final int KEYS = 1;
  public static final int APC = 2;

  private boolean enabled = false;
  private final String name;
  private final int mode;
  private int octaveShift = 0;

  class NoteMeta {
    int channel;
    int number;
    NoteMeta(int channel, int number) {
      this.channel = channel;
      this.number = number;
    }
  }

  final Map<Character, NoteMeta> keyToNote = new HashMap<Character, NoteMeta>();

  final List<SCMidiInputListener> listeners = new ArrayList<SCMidiInputListener>();

  public SCMidiInput addListener(SCMidiInputListener l) {
    listeners.add(l);
    return this;
  }

  public SCMidiInput removeListener(SCMidiInputListener l) {
    listeners.remove(l);
    return this;
  }

  SCMidiInput(MidiInputDevice d) {
    mode = MIDI;
    d.createInput(this);
    name = d.getName().replace("Unknown vendor","");
  }

  SCMidiInput(int mode) {
    this.mode = mode;
    switch (mode) {
    case APC:
      name = "QWERTY (APC Mode)";
      mapAPC();
      break;
    default:
    case KEYS:
      name = "QWERTY (Key Mode)";
      mapKeys();
      break;
    }
  }

  private void mapAPC() {
    mapNote('1', 0, 53);
    mapNote('2', 1, 53);
    mapNote('3', 2, 53);
    mapNote('4', 3, 53);
    mapNote('5', 4, 53);
    mapNote('6', 5, 53);
    mapNote('q', 0, 54);
    mapNote('w', 1, 54);
    mapNote('e', 2, 54);
    mapNote('r', 3, 54);
    mapNote('t', 4, 54);
    mapNote('y', 5, 54);
    mapNote('a', 0, 55);
    mapNote('s', 1, 55);
    mapNote('d', 2, 55);
    mapNote('f', 3, 55);
    mapNote('g', 4, 55);
    mapNote('h', 5, 55);
    mapNote('z', 0, 56);
    mapNote('x', 1, 56);
    mapNote('c', 2, 56);
    mapNote('v', 3, 56);
    mapNote('b', 4, 56);
    mapNote('n', 5, 56);
    registerKeyEvent(this);
  }

  private void mapKeys() {
    int note = 48;
    mapNote('a', 1, note++);
    mapNote('w', 1, note++);
    mapNote('s', 1, note++);
    mapNote('e', 1, note++);
    mapNote('d', 1, note++);
    mapNote('f', 1, note++);
    mapNote('t', 1, note++);
    mapNote('g', 1, note++);
    mapNote('y', 1, note++);
    mapNote('h', 1, note++);
    mapNote('u', 1, note++);
    mapNote('j', 1, note++);
    mapNote('k', 1, note++);
    mapNote('o', 1, note++);
    mapNote('l', 1, note++);
    registerKeyEvent(this);
  }

  void mapNote(char ch, int channel, int number) {
    keyToNote.put(ch, new NoteMeta(channel, number));
  }

  public String getLabel() {
    return name;
  }

  public void keyEvent(KeyEvent e) {
    if (!enabled) {
      return;
    }
    char c = Character.toLowerCase(e.getKeyChar());
    NoteMeta nm = keyToNote.get(c);
    if (nm != null) {
      switch (e.getID()) {
      case KeyEvent.KEY_PRESSED:
        noteOnReceived(new Note(Note.NOTE_ON, nm.channel, nm.number + octaveShift*12, 127));
        break;
      case KeyEvent.KEY_RELEASED:
        noteOffReceived(new Note(Note.NOTE_OFF, nm.channel, nm.number + octaveShift*12, 0));
        break;
      }
    }
    if ((mode == KEYS) && (e.getID() == KeyEvent.KEY_PRESSED)) {
      switch (c) {
      case 'z':
        octaveShift = constrain(octaveShift-1, -4, 4);
        break;
      case 'x':
        octaveShift = constrain(octaveShift+1, -4, 4);
        break;
      }
    }
  }

  public boolean isEnabled() {
    return enabled;
  }

  public boolean isSelected() {
    return enabled;
  }

  public void onMousePressed() {
    setEnabled(!enabled);
  }

  public SCMidiInput setEnabled(boolean enabled) {
    if (enabled != this.enabled) {
      this.enabled = enabled;
      for (SCMidiInputListener l : listeners) {
        l.onEnabled(this, enabled);
      }
    }
    return this;
  }

  protected SCPattern getFocusedPattern() {
    return (SCPattern) midiEngine.getFocusedDeck().getActivePattern();
  }

  private boolean logMidi() {
    return (uiMidi != null) && uiMidi.logMidi();
  }

  final void programChangeReceived(ProgramChange pc) {
    if (!enabled) {
      return;
    }
    if (logMidi()) {
      println(getLabel() + " :: Program Change :: " + pc.getNumber());
    }
    handleProgramChange(pc);
  }

  final void controllerChangeReceived(rwmidi.Controller cc) {
    if (!enabled) {
      return;
    }
    if (logMidi()) {
      println(getLabel() + " :: Controller :: " + cc.getCC() + ":" + cc.getValue());
    }
    if (!getFocusedPattern().controllerChangeReceived(cc)) {
      handleControllerChange(cc);
    }
  }

  final void noteOnReceived(Note note) {
    if (!enabled) {
      return;
    }
    if (logMidi()) {
      println(getLabel() + " :: Note On  :: " + note.getChannel() + ":" + note.getPitch() + ":" + note.getVelocity());
    }
    if (!getFocusedPattern().noteOnReceived(note)) {
      handleNoteOn(note);
    }
  }

  final void noteOffReceived(Note note) {
    if (!enabled) {
      return;
    }
    if (logMidi()) {
      println(getLabel() + " :: Note Off :: " + note.getChannel() + ":" + note.getPitch() + ":" + note.getVelocity());
    }
    if (!getFocusedPattern().noteOffReceived(note)) {
      handleNoteOff(note);
    }
  }

  // Subclasses may implement these to map top-level functionality
  protected void handleProgramChange(ProgramChange pc) {
  }
  protected void handleControllerChange(rwmidi.Controller cc) {
  }
  protected void handleNoteOn(Note note) {
  }
  protected void handleNoteOff(Note note) {
  }
}

public class APC40MidiInput extends SCMidiInput {

  private boolean shiftOn = false;
  private LXEffect releaseEffect = null;
  
  APC40MidiInput(MidiInputDevice d) {
    super(d);
  }

  protected void handleControllerChange(rwmidi.Controller cc) {
    int number = cc.getCC();
    switch (number) {
    // Crossfader
    case 15:
      lx.engine.getDeck(1).getCrossfader().setValue(cc.getValue() / 127.);
      break;
    }
    
    int parameterIndex = -1;
    if (number >= 48 && number <= 55) {
      parameterIndex = number - 48;
    } else if (number >= 16 && number <= 19) {
      parameterIndex = 8 + (number-16);
    }
    if (parameterIndex >= 0) {
      List<LXParameter> parameters = getFocusedPattern().getParameters();
      if (parameterIndex < parameters.size()) {
        parameters.get(parameterIndex).setValue(cc.getValue() / 127.);
      }
    }
    
    if (number >= 20 && number <= 23) {
      int effectIndex = number - 20;
      List<LXParameter> parameters = glucose.getSelectedEffect().getParameters();
      if (effectIndex < parameters.size()) {
        parameters.get(effectIndex).setValue(cc.getValue() / 127.);
      }
    }
  }

  

	private double Tap1 = 0;
	private double  getNow() { return millis() + 1000*second() + 60*1000*minute() + 3600*1000*hour(); }
	private boolean dbtwn  	(double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}

  protected void handleNoteOn(Note note) {
	int nPitch = note.getPitch(), nChan = note.getChannel();
    switch (nPitch) {
		
	case 82:	EFF_boom	.trigger(); 				break;	// BOOM!
	case 83:	EFF_flash	.trigger(); 				break;	// Flash
		
	case 90:	lx.tempo.trigger(); Tap1 = getNow(); 	break;	// dan's dirty tapping mechanism
    case 94: // right bank
      midiEngine.setFocusedDeck(1);
      break;
    case 95: // left bank
      midiEngine.setFocusedDeck(0);
      break;
    case 96: // up bank
      if (shiftOn) {
        glucose.incrementSelectedEffectBy(1);
      } else {
        midiEngine.getFocusedDeck().goNext();
      }
      break;
    case 97: // down bank
      if (shiftOn) {
        glucose.incrementSelectedEffectBy(-1);
      } else {
        midiEngine.getFocusedDeck().goPrev();
      }
      break;

    case 98: // shift
      shiftOn = true;
      break;

    case 99: // tap tempo
      lx.tempo.tap();
      break;
    case 100: // nudge+
      lx.tempo.setBpm(lx.tempo.bpm() + (shiftOn ? 1 : .1));
      break;
    case 101: // nudge-
      lx.tempo.setBpm(lx.tempo.bpm() - (shiftOn ? 1 : .1));
      break;

    case 91: // play
    case 93: // rec
      releaseEffect = glucose.getSelectedEffect(); 
      if (releaseEffect.isMomentary()) {
        releaseEffect.enable();
      } else {
        releaseEffect.toggle();
      }
      break;

    case 92: // stop
      glucose.getSelectedEffect().disable();
      break;
    }
  }

  protected void handleNoteOff(Note note) {
	int nPitch = note.getPitch(), nChan = note.getChannel();
    switch (nPitch) {
	case 90:
		if (dbtwn(getNow() - Tap1,5000,300*1000)) {	// hackish tapping mechanism
			double bpm = 32.*60000./(getNow()-Tap1);
			while (bpm < 20) bpm*=2;
			while (bpm > 40) bpm/=2;
			lx.tempo.setBpm(bpm); lx.tempo.trigger(); Tap1=0; println("Tap Set - " + bpm + " bpm");
		}
		break;

    case 93: // rec
      if (releaseEffect != null) {
        if (releaseEffect.isMomentary()) {
          releaseEffect.disable();
        }
      }
      break;
		
    case 98: // shift
      shiftOn = false;
       break;
    }
  }
}

class KorgNanoKontrolMidiInput extends SCMidiInput {
  
  KorgNanoKontrolMidiInput(MidiInputDevice d) {
    super(d);
  }
  
  protected void handleControllerChange(rwmidi.Controller cc) {
    int number = cc.getCC();
    if (number >= 16 && number <= 23) {
      int parameterIndex = number - 16;
      List<LXParameter> parameters = getFocusedPattern().getParameters();
      if (parameterIndex < parameters.size()) {
        parameters.get(parameterIndex).setValue(cc.getValue() / 127.);
      }
    }
    
    if (cc.getValue() == 127) {
      switch (number) {
      // Left track
      case 58:
        midiEngine.setFocusedDeck(0);
        break;
      // Right track
      case 59:
        midiEngine.setFocusedDeck(1);
        break;
      // Left chevron
      case 43:
        midiEngine.getFocusedDeck().goPrev();
        break;
      // Right chevron
      case 44:
        midiEngine.getFocusedDeck().goNext();
        break;
      }
    }
  }
}

