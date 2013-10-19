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

  public final GridController grid;
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
    grid = new GridController(this);
    midiControllers.add(midiQwertyKeys = new VirtualKeyMidiInput(this, VirtualKeyMidiInput.KEYS));
    midiControllers.add(midiQwertyAPC = new VirtualKeyMidiInput(this, VirtualKeyMidiInput.APC));
    int apcCount = 0;
    for (MidiInputDevice device : RWMidi.getInputDevices()) {
      if (device.getName().contains("APC")) {
        ++apcCount;
      }
    }    
    
    int apcIndex = 0;
    for (MidiInputDevice device : RWMidi.getInputDevices()) {
      if (device.getName().contains("APC")) {
        int apcDeck = -1;
        if (apcCount > 1 && apcIndex < 2) {
          apcDeck = apcIndex++;
        }
        midiControllers.add(new APC40MidiInput(this, device, apcDeck).setEnabled(true));
      } else if (device.getName().contains("SLIDER/KNOB KORG")) {
        midiControllers.add(new KorgNanoKontrolMidiInput(this, device).setEnabled(true));
      } else {
        boolean enabled = device.getName().contains("KEYBOARD KORG") || device.getName().contains("Bus 1 Apple");
        midiControllers.add(new GenericDeviceMidiInput(this, device).setEnabled(enabled));
      }
    }
    
    apcIndex = 0;
    for (MidiOutputDevice device : RWMidi.getOutputDevices()) {
      if (device.getName().contains("APC")) {
        int apcDeck = -1;
        if (apcCount > 1 && apcIndex < 2) {
          apcDeck = apcIndex++;
        }
        new APC40MidiOutput(this, device, apcDeck);
      }
    }
  }

  public List<SCMidiInput> getControllers() {
    return this.midiControllers;
  }

  public Engine.Deck getFocusedDeck() {
    return lx.engine.getDeck(activeDeckIndex);
  }

  public SCPattern getFocusedPattern() {
    return (SCPattern) getFocusedDeck().getActivePattern();
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

  public boolean isQwertyEnabled() {
    return midiQwertyKeys.isEnabled() || midiQwertyAPC.isEnabled();
  }
}

public interface SCMidiInputListener {
  public void onEnabled(SCMidiInput controller, boolean enabled);
}

public abstract class SCMidiInput extends AbstractScrollItem {

  protected boolean enabled = false;
  private final String name;

  protected final MidiEngine midiEngine;

  final List<SCMidiInputListener> listeners = new ArrayList<SCMidiInputListener>();

  protected SCMidiInput(MidiEngine midiEngine, String name) {
    this.midiEngine = midiEngine;
    this.name = name;
  }

  public SCMidiInput addListener(SCMidiInputListener l) {
    listeners.add(l);
    return this;
  }

  public SCMidiInput removeListener(SCMidiInputListener l) {
    listeners.remove(l);
    return this;
  }

  public String getLabel() {
    return name;
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

  private boolean logMidi() {
    return (uiMidi != null) && uiMidi.logMidi();
  }
  
  protected SCPattern getTargetPattern() {
    return midiEngine.getFocusedPattern();
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
      println(getLabel() + " :: Controller :: " + cc.getChannel() + " :: " + cc.getCC() + ":" + cc.getValue());
    }
    if (!handleGridControllerChange(cc)) {
      if (!getTargetPattern().controllerChange(cc)) {
        handleControllerChange(cc);
      }
    }
  }

  final void noteOnReceived(Note note) {
    if (!enabled) {
      return;
    }
    if (logMidi()) {
      println(getLabel() + " :: Note On  :: " + note.getChannel() + ":" + note.getPitch() + ":" + note.getVelocity());
    }
    if (!handleGridNoteOn(note)) {
      if (!getTargetPattern().noteOn(note)) {
        handleNoteOn(note);
      }
    }
  }

  final void noteOffReceived(Note note) {
    if (!enabled) {
      return;
    }
    if (logMidi()) {
      println(getLabel() + " :: Note Off :: " + note.getChannel() + ":" + note.getPitch() + ":" + note.getVelocity());
    }
    if (!handleGridNoteOff(note)) {
      if (!getTargetPattern().noteOff(note)) {
        handleNoteOff(note);
      }
    }
  }

  // Subclasses may implement these to map top-level functionality
  protected boolean handleGridNoteOn(Note note) { return false; }
  protected boolean handleGridNoteOff(Note note) { return false; }
  protected boolean handleGridControllerChange(rwmidi.Controller cc) { return false; }
  protected void handleProgramChange(ProgramChange pc) {}
  protected void handleControllerChange(rwmidi.Controller cc) {}
  protected void handleNoteOn(Note note) {}
  protected void handleNoteOff(Note note) {}
}

public class VirtualKeyMidiInput extends SCMidiInput {

  public static final int KEYS = 1;
  public static final int APC = 2;
  
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
  
  VirtualKeyMidiInput(MidiEngine midiEngine, int mode) {
    super(midiEngine, "QWERTY (" + (mode == APC ? "APC" : "Key") + "  Mode)");
    this.mode = mode;
    if (mode == APC) {
      mapAPC();
    } else {
      mapKeys();
    }
    registerKeyEvent(this);    
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
  }

  void mapNote(char ch, int channel, int number) {
    keyToNote.put(ch, new NoteMeta(channel, number));
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
}

public class GenericDeviceMidiInput extends SCMidiInput {
  GenericDeviceMidiInput(MidiEngine midiEngine, MidiInputDevice d) {
    super(midiEngine, d.getName().replace("Unknown vendor",""));
    d.createInput(this);
  }
}

public class APC40MidiInput extends GenericDeviceMidiInput {

  private boolean shiftOn = false;
  private LXEffect releaseEffect = null;
  final private Engine.Deck targetDeck;
  
  APC40MidiInput(MidiEngine midiEngine, MidiInputDevice d) {
    this(midiEngine, d, -1);
  }
  
  APC40MidiInput(MidiEngine midiEngine, MidiInputDevice d, int deckIndex) {
    super(midiEngine, d);
    targetDeck = (deckIndex < 0) ? null : lx.engine.getDecks().get(deckIndex);
  }
  
  protected Engine.Deck getTargetDeck() {
    if (targetDeck != null) {
      return targetDeck;
    }
    return midiEngine.getFocusedDeck();
  }
  
  protected SCPattern getTargetPattern() {
    if (targetDeck != null) {
      return (SCPattern) (targetDeck.getActivePattern());
    }
    return super.getTargetPattern();
  }

  private class GridPosition {
    public final int row, col;
    GridPosition(int r, int c) {
      row = r;
      col = c;
    }
  }
  
  private GridPosition getGridPosition(Note note) {
    int channel = note.getChannel();
    int pitch = note.getPitch();
    if (channel < 8) {
      if (pitch >= 53 && pitch <=57) return new GridPosition(pitch-53, channel);
    }
    return null;
  }

  protected boolean handleGridNoteOn(Note note) {
    GridPosition p = getGridPosition(note);
    if (p != null) {
      return midiEngine.grid.gridPressed(p.row, p.col);
    }
    return false;
  }

  protected boolean handleGridNoteOff(Note note) {
    GridPosition p = getGridPosition(note);
    if (p != null) {
      return midiEngine.grid.gridReleased(p.row, p.col);
    }
    return false;
  }

  protected void handleControllerChange(rwmidi.Controller cc) {
    int channel = cc.getChannel();
    int number = cc.getCC();
    float value = cc.getValue() / 127.;
    switch (number) {
      
    case 7:
     switch (channel) {
       case 0:
         EFF_colorFucker.hueShift.setValue(value);
         break;
       case 1:
         EFF_colorFucker.desat.setValue(value);
         break;
       case 2:
         EFF_colorFucker.sharp.setValue(value);
         break;
       case 3:
         EFF_blur.amount.setValue(value);
         break;
       case 4:
         EFF_quantize.amount.setValue(value);
         break;
     }
     break;
     
    // Master bright
    case 14:
      EFF_colorFucker.level.setValue(value);
      break;

    // Crossfader
    case 15:
      lx.engine.getDeck(1).getCrossfader().setValue(value);
      break;
    }
    
    int parameterIndex = -1;
    if (number >= 48 && number <= 55) {
      parameterIndex = number - 48;
    } else if (number >= 16 && number <= 19) {
      parameterIndex = 8 + (number-16);
    }
    if (parameterIndex >= 0) {
      List<LXParameter> parameters = getTargetPattern().getParameters();
      if (parameterIndex < parameters.size()) {
        parameters.get(parameterIndex).setValue(value);
      }
    }
    
    if (number >= 20 && number <= 23) {
      int effectIndex = number - 20;
      List<LXParameter> parameters = glucose.getSelectedEffect().getParameters();
      if (effectIndex < parameters.size()) {
        parameters.get(effectIndex).setValue(value);
      }
    }
  }

  private long tap1 = 0;

  private boolean lbtwn(long a, long b, long c) {
    return a >= b && a <= c;
  }

  protected void handleNoteOn(Note note) {
    int nPitch = note.getPitch();
    int nChan = note.getChannel();
    switch (nPitch) {
    
    case 49: // SOLO/CUE
      switch (nChan) {
        case 4:
          EFF_colorFucker.mono.setValue(1);
          break;
        case 5:
          EFF_colorFucker.invert.setValue(1);
          break;
        case 6:
          lx.cycleBaseHue(60000);
          break;
      }
      break;
            
    case 82: // scene 1
      EFF_boom.trigger();
      break;
      
    case 83: // scene 2
      EFF_flash.trigger();
      break;
      
    case 90:
      // dan's dirty tapping mechanism
      lx.tempo.trigger();
      tap1 = millis();
      break;

    case 91: // play
    case 97: // left bank
      midiEngine.setFocusedDeck(0);
      break;

    case 93: // rec
    case 96: // right bank
      midiEngine.setFocusedDeck(1);
      break;

    case 94: // up bank
      if (shiftOn) {
        glucose.incrementSelectedEffectBy(-1);
      } else {
        getTargetDeck().goPrev();
      }
      break;
    case 95: // down bank
      if (shiftOn) {
        glucose.incrementSelectedEffectBy(1);
      } else {
        getTargetDeck().goNext();
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

    case 62: // Detail View / red 5
      releaseEffect = glucose.getSelectedEffect(); 
      if (releaseEffect.isMomentary()) {
        releaseEffect.enable();
      } else {
        releaseEffect.toggle();
      }
      break;

    case 63: // rec quantize / red 6
      glucose.getSelectedEffect().disable();
      break;
    }
  }

  protected void handleNoteOff(Note note) {
    int nPitch = note.getPitch();
    int nChan = note.getChannel();

    switch (nPitch) {
      
    case 49: // SOLO/CUE
      switch (nChan) {
        case 4:
          EFF_colorFucker.mono.setValue(0);
          break;
        case 5:
          EFF_colorFucker.invert.setValue(0);
          break;
        case 6:
          lx.setBaseHue(lx.getBaseHue());
          break;
      }
      break;

    case 52: // CLIP STOP
      if (nChan < PresetManager.NUM_PRESETS) {
        if (shiftOn) {
          presetManager.store(nChan);
        } else {
          presetManager.select(nChan);
        }
      }
      break;

    case 90: // SEND C
      long tapDelta = millis() - tap1;
      if (lbtwn(tapDelta,5000,300*1000)) {	// hackish tapping mechanism
        double bpm = 32.*60000./(tapDelta);
        while (bpm < 20) bpm*=2;
        while (bpm > 40) bpm/=2;
        lx.tempo.setBpm(bpm);
        lx.tempo.trigger();
        tap1 = 0;
        println("Tap Set - " + bpm + " bpm");
      }
      break;

    case 63: // rec quantize / RED 6
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

class KorgNanoKontrolMidiInput extends GenericDeviceMidiInput {
  
  KorgNanoKontrolMidiInput(MidiEngine midiEngine, MidiInputDevice d) {
    super(midiEngine, d);
  }
  
  protected void handleControllerChange(rwmidi.Controller cc) {
    int number = cc.getCC();
    if (number >= 16 && number <= 23) {
      int parameterIndex = number - 16;
      List<LXParameter> parameters = midiEngine.getFocusedPattern().getParameters();
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

class APC40MidiOutput implements LXParameter.Listener, GridOutput {
  
  private final MidiEngine midiEngine;
  private final MidiOutput output;
  private LXPattern focusedPattern = null;
  private LXEffect focusedEffect = null;
  private final Engine.Deck targetDeck;
  
  APC40MidiOutput(MidiEngine midiEngine, MidiOutputDevice device) {
    this(midiEngine, device, -1);
  }
  
  APC40MidiOutput(MidiEngine midiEngine, MidiOutputDevice device, int deckIndex) {
    this.midiEngine = midiEngine;
    output = device.createOutput();
    targetDeck = (deckIndex < 0) ? null : lx.engine.getDecks().get(deckIndex);
    setDPatternOutputs();
    if (targetDeck != null) {
      midiEngine.addListener(new MidiEngineListener() {
        public void onFocusedDeck(int deckIndex) {
          resetPatternParameters();
        }
      });
    }
    glucose.addEffectListener(new GLucose.EffectListener() {
      public void effectSelected(LXEffect effect) {
        resetEffectParameters();
      }
    });
    Engine.Listener deckListener = new Engine.AbstractListener() {
      public void patternDidChange(Engine.Deck deck, LXPattern pattern) {
        resetPatternParameters();
      }
    };
    for (Engine.Deck d : lx.engine.getDecks()) {
      if (targetDeck == null || d == targetDeck) {
        d.addListener(deckListener);
      }
    }
    presetManager.addListener(new PresetListener() {
      public void onPresetLoaded(Preset preset) {
        for (int i = 0; i < 8; ++i) {
          output.sendNoteOn(i, 52, (preset.index == i) ? 1 : 0);
        }
      }
      public void onPresetDirty(Preset preset) {
        output.sendNoteOn(preset.index, 52, 2);
      }
      public void onPresetStored(Preset preset) {
        onPresetLoaded(preset);
      }
      public void onPresetUnloaded() {
        for (int i = 0; i < 8; ++i) {
          output.sendNoteOn(i, 52, 0);
        }
      }
    });
    resetParameters();
    midiEngine.grid.addOutput(this);

    lx.cycleBaseHue(60000);
    output.sendNoteOn(6, 49, 127);
    
    // Turn off the track selection lights and preset selectors
    for (int i = 0; i < 8; ++i) {
      output.sendNoteOn(i, 51, 0);
      output.sendNoteOn(i, 52, 0);
    }
    
    // Turn off the MASTER selector
    output.sendNoteOn(0, 80, 0);
  }
  
  private void setDPatternOutputs() {
    for (Engine.Deck deck : lx.engine.getDecks()) {
      if (targetDeck == null || deck == targetDeck) {
        for (LXPattern pattern : deck.getPatterns()) {
          if (pattern instanceof DPat) {
            ((DPat)pattern).setAPCOutput(output);
          }
        }
      }
    }
  }
  
  protected Engine.Deck getTargetDeck() {
    if (targetDeck != null) {
      return targetDeck;
    }
    return midiEngine.getFocusedDeck();
  }

  private void resetParameters() {
    resetPatternParameters();
    resetEffectParameters();
  }
  
  private void resetPatternParameters() {
    LXPattern newPattern = getTargetDeck().getActivePattern();
    if (newPattern == focusedPattern) {
      return;
    }
    if (focusedPattern != null) {
      for (LXParameter p : focusedPattern.getParameters()) {
        ((LXListenableParameter) p).removeListener(this);
      }
    }
    focusedPattern = newPattern;
    int i = 0;
    for (LXParameter p : focusedPattern.getParameters()) {
      ((LXListenableParameter) p).addListener(this);
      sendKnob(i++, p);
    }
    while (i < 12) {
      sendKnob(i++, 0);
    }
    if (focusedPattern instanceof DPat) {
      ((DPat)focusedPattern).updateLights();
    } else {
      for (int j = 0; j < 8; ++j) {
        output.sendNoteOn(j, 48, 0);
      }
      for (int row = 0; row < 7; ++row) {
        for (int col = 0; col < 8; ++col) {
          setGridState(row, col, 0);
        }
      }
    }
  }
  
  private void resetEffectParameters() {
    LXEffect newEffect = glucose.getSelectedEffect();
    if (newEffect == focusedEffect) {
      return;
    }
    if (focusedEffect != null) {
      for (LXParameter p : focusedPattern.getParameters()) {
        ((LXListenableParameter) p).removeListener(this);
      }
    }
    focusedEffect = newEffect;
    int i = 0;
    for (LXParameter p : focusedEffect.getParameters()) {
      ((LXListenableParameter) p).addListener(this);
      sendKnob(12 + i++, p);
    }
    while (i < 4) {
      sendKnob(12 + i++, 0);
    }
  }

  private void sendKnob(int i, LXParameter p) {
    sendKnob(i, (int) (p.getValuef() * 127.));
  }
  
  private void sendKnob(int i, int value) {
    if (i < 8) {
      output.sendController(0, 48+i, value);
    } else if (i < 16) {
      output.sendController(0, 8+i, value);
    }
  }
  
  public void onParameterChanged(LXParameter parameter) {
    int i = 0;
    for (LXParameter p : focusedPattern.getParameters()) {
      if (p == parameter) {
        sendKnob(i, p);
        break;
      }
      ++i;
    }
    i = 12;
    for (LXParameter p : focusedEffect.getParameters()) {
      if (p == parameter) {
        sendKnob(i, p);
        break;
      }
      ++i;
    }
  }
  
  public void setGridState(int row, int col, int state) {
    if (col < 8 && row < 5) {
      output.sendNoteOn(col, 53+row, state);
    }
  }
}

interface GridOutput {
  public static final int OFF = 0;
  public static final int GREEN = 1;
  public static final int GREEN_BLINK = 2;
  public static final int RED = 3;
  public static final int RED_BLINK = 4;
  public static final int YELLOW = 5;
  public static final int YELLOW_BLINK = 6;
  public static final int ON = 127;
  
  public void setGridState(int row, int col, int state);
}

class GridController {
  private final List<GridOutput> outputs = new ArrayList<GridOutput>();
  
  private final MidiEngine midiEngine;
  
  GridController(MidiEngine midiEngine) {
    this.midiEngine = midiEngine;
  }
  
  public void addOutput(GridOutput output) {
    outputs.add(output);
  }
  
  public boolean gridPressed(int row, int col) {
    return midiEngine.getFocusedPattern().gridPressed(row, col);
  }
  
  public boolean gridReleased(int row, int col) {
    return midiEngine.getFocusedPattern().gridReleased(row, col);
  }
  
  public void setState(int row, int col, int state) {
    for (GridOutput g : outputs) {
      g.setGridState(row, col, state);
    }
  }
}

