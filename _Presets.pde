interface PresetListener {
  public void onPresetSelected(LXDeck deck, Preset preset);
  public void onPresetStored(LXDeck deck, Preset preset);
  public void onPresetDirty(LXDeck deck, Preset preset);
}

class PresetManager {
  
  public static final int NUM_PRESETS = 8;
  public static final String FILENAME = "data/presets.txt";
  public static final String DELIMITER = "\t";
  
  class DeckState implements LXParameterListener {
    
    final LXDeck deck;
    LXPattern selectedPattern = null;    
    Preset selectedPreset = null;
    boolean isDirty = false;

    DeckState(LXDeck deck) {
      this.deck = deck;
      deck.addListener(new LXDeck.AbstractListener() {
        public void patternDidChange(LXDeck deck, LXPattern pattern) {
          if (selectedPattern != pattern) {
            onDirty();
          }
        }
      });
    }

    private void onSelect(Preset preset, LXPattern pattern) {
      if ((selectedPattern != pattern) && (selectedPattern != null)) {
        for (LXParameter p : selectedPattern.getParameters()) {
          ((LXListenableParameter) p).removeListener(this);
        }
      }
      selectedPreset = preset;
      selectedPattern = pattern;
      isDirty = false;
      for (LXParameter p : pattern.getParameters()) {
        ((LXListenableParameter) p).addListener(this);
      }
      for (PresetListener listener : listeners) {
        listener.onPresetSelected(deck, preset);
      }
    }
    
    private void onStore(Preset preset, LXPattern pattern) {
      selectedPreset = preset;
      selectedPattern = pattern;
      isDirty = false;
      for (PresetListener listener : listeners) {
        listener.onPresetStored(deck, preset);
      }
    }
    
    private void onDirty() {
      if (selectedPreset != null) {
        isDirty = true;
        for (PresetListener listener : listeners) {
          listener.onPresetDirty(deck, selectedPreset);
        }
      }
    }
    
    public void onParameterChanged(LXParameter parameter) {
      onDirty();
    }
  }
  
  private final DeckState[] deckState = new DeckState[lx.engine.getDecks().size()];
  private final Preset[] presets = new Preset[NUM_PRESETS];
  private final List<PresetListener> listeners = new ArrayList<PresetListener>();
  
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
    for (LXDeck deck : lx.engine.getDecks()) {
      deckState[deck.index] = new DeckState(deck);
    }
  }
  
  public void addListener(PresetListener listener) {
    listeners.add(listener);
  }
  
  public void select(LXDeck deck, int index) {
    presets[index].select(deck);
  }

  public void store(LXDeck deck, int index) {
    presets[index].store(deck);
  }
  
  public void dirty(LXDeck deck) {
    deckState[deck.index].onDirty();
  }
  
  public void dirty(LXPattern pattern) {
    dirty(pattern.getDeck());
  }

  public void onStore(LXDeck deck, Preset preset, LXPattern pattern) {
    deckState[deck.index].onStore(preset, pattern);
  }
  
  public void onSelect(LXDeck deck, Preset preset, LXPattern pattern) {
    deckState[deck.index].onSelect(preset, pattern);
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
  
  public void store(LXDeck deck) {
    LXPattern pattern = deck.getActivePattern();
    className = pattern.getClass().getName();
    parameters.clear();
    for (LXParameter p : pattern.getParameters()) {
      parameters.put(p.getLabel(), p.getValuef());
    }
    if (pattern instanceof DPat) {
      DPat dpattern = (DPat) pattern;
      for (DBool bool : dpattern.bools) {
        parameters.put(bool.tag, bool.b ? 1.f : 0.f);
      }
      for (Pick pick : dpattern.picks) {
        parameters.put(pick.tag, pick.CurRow + pick.CurCol/100.f);
      }
    }
    manager.write();
    manager.onStore(deck, this, pattern);
  }
  
  public void select(LXDeck deck) {
    for (LXPattern pattern : deck.getPatterns()) {
      if (pattern.getClass().getName().equals(className)) {
        for (String pLabel : parameters.keySet()) {
          for (LXParameter p : pattern.getParameters()) {
            if (p.getLabel().equals(pLabel)) {
              p.setValue(parameters.get(pLabel));
            }
          }
          if (pattern instanceof DPat) {
            DPat dpattern = (DPat) pattern;
            for (DBool bool : dpattern.bools) {
              if (bool.tag.equals(pLabel)) {
                bool.set(bool.row, bool.col, parameters.get(pLabel) > 0);
              }
            }
            for (Pick pick : dpattern.picks) {
              if (pick.tag.equals(pLabel)) {
                float f = parameters.get(pLabel);
                pick.set((int) floor(f), (int) round((f%1)*100.));
              }
            }
          }
        }
        deck.goPattern(pattern);
        if (pattern instanceof DPat) {
          ((DPat)pattern).updateLights();
        }
        manager.onSelect(deck, this, pattern);
        break;
      }
    }
  }
}

