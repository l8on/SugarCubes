interface PresetListener {
  public void onPresetLoaded(Preset preset);
  public void onPresetDirty(Preset preset);
  public void onPresetStored(Preset preset);
  public void onPresetUnloaded();
}

class PresetManager implements LXParameter.Listener {
  
  public static final int NUM_PRESETS = 8;
  public static final String FILENAME = "data/presets.txt";
  public static final String DELIMITER = "\t";
  
  private final Preset[] presets = new Preset[NUM_PRESETS];
  private final List<PresetListener> listeners = new ArrayList<PresetListener>();
  
  private Preset loadedPreset = null;
  private LXPattern loadedPattern = null;
  
  PresetManager() {
    for (int i = 0; i < presets.length; ++i) {
      presets[i] = new Preset(this, i);
    }
    String[] values = loadStrings(FILENAME);
    if (values == null) {
      write();
    } else {
      int i = 0;
      for (String serialized : values) {
        presets[i++].load(serialized);
        if (i >= NUM_PRESETS) {
          break;
        }
      }
    }
    for (Engine.Deck deck : lx.engine.getDecks()) {
      deck.addListener(new Engine.AbstractListener() {
        public void patternDidChange(Engine.Deck deck, LXPattern pattern) {
          if (midiEngine.getFocusedDeck() == deck) {
            if (pattern != loadedPattern) {
              onPresetDirty();
            }
          }
        }
      });
    }
  }
  
  public void setMidiEngine(MidiEngine midiEngine) {
    midiEngine.addListener(new MidiEngineListener() {
      public void onFocusedDeck(int deckIndex) {
        loadedPreset = null;
        for (PresetListener listener : listeners) {
          listener.onPresetUnloaded();
        }
      }
    });
  }
  
  public void addListener(PresetListener listener) {
    listeners.add(listener);
  }

  public void select(int index) {
    presets[index].select();
  }

  public void store(int index) {
    presets[index].store(midiEngine.getFocusedPattern());
    for (PresetListener listener : listeners) {
      listener.onPresetStored(presets[index]);
    }
    select(index);
  }
  
  public void onPresetLoaded(Preset preset, LXPattern pattern) {
    if (loadedPattern != pattern) {
      if (loadedPattern != null) {
        for (LXParameter p : loadedPattern.getParameters()) {
          ((LXListenableParameter) p).removeListener(this);
        }
      }
    }
    for (PresetListener listener : listeners) {
      listener.onPresetLoaded(preset);
    }
    loadedPreset = preset;
    loadedPattern = pattern;
    for (LXParameter p : loadedPattern.getParameters()) {
      ((LXListenableParameter) p).addListener(this);
    }
  }
  
  private void onPresetDirty() {
    if (loadedPreset != null) {
      for (PresetListener listener : listeners) {
        listener.onPresetDirty(loadedPreset);
      }
    }
  }
  
  public void onParameterChanged(LXParameter p) {
    onPresetDirty();
  }
  
  public void write() {
    String[] lines = new String[NUM_PRESETS];
    int i = 0;
    for (Preset preset : presets) {
      lines[i++] = preset.serialize(); 
    }
    saveStrings(FILENAME, lines);
  }
}

class Preset {
  
  final PresetManager manager;
  final int index;
  
  String className;
  final Map<String, Float> parameters = new HashMap<String, Float>();
  
  Preset(PresetManager manager, int index) {
    this.manager = manager;
    this.index = index;
  }
  
  public void load(String serialized) {
    className = null;
    parameters.clear();
    try {
      String[] parts = serialized.split(PresetManager.DELIMITER);
      className = parts[0];
      int i = 1;
      while (i < parts.length - 1) {
        parameters.put(parts[i], Float.parseFloat(parts[i+1]));
        i += 2;
      }
    } catch (Exception x) {
      className = null;
      parameters.clear();
    }
  }
  
  public String serialize() {
    if (className == null) {
      return "null";
    }
    String val = className + PresetManager.DELIMITER;
    for (String pKey : parameters.keySet()) {
      val += pKey + PresetManager.DELIMITER + parameters.get(pKey) + PresetManager.DELIMITER;
    }
    return val;
  }
  
  public void store(LXPattern pattern) {
    className = null;
    parameters.clear();
    className = pattern.getClass().getName();
    for (LXParameter p : pattern.getParameters()) {
      parameters.put(p.getLabel(), p.getValuef());
    }
    manager.write();
  }
  
  public void select() {
    Engine.Deck deck = midiEngine.getFocusedDeck();
    for (LXPattern pattern : deck.getPatterns()) {
      if (pattern.getClass().getName().equals(className)) {
        for (String pLabel : parameters.keySet()) {
          for (LXParameter p : pattern.getParameters()) {
            if (p.getLabel().equals(pLabel)) {
              p.setValue(parameters.get(pLabel));
            }
          }
        }
        deck.goPattern(pattern);
        manager.onPresetLoaded(this, pattern);
        break;
      }
    }    
  }
}

