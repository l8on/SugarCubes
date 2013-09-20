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
 * Little UI framework in progress to handle mouse events, layout,
 * redrawing, etc.
 */

final color lightGreen = #669966;
final color lightBlue = #666699;
final color bgGray = #444444;
final color defaultTextColor = #999999;
final PFont defaultItemFont = createFont("Lucida Grande", 11);
final PFont defaultTitleFont = createFont("Myriad Pro", 10);

public abstract class UIObject {
  
  protected final List<UIObject> children = new ArrayList<UIObject>();  

  protected boolean needsRedraw = true;
  protected boolean childNeedsRedraw = true;
  
  protected float x=0, y=0, w=0, h=0;
  
  public UIContainer parent = null;
  
  protected boolean visible = true;
  
  public UIObject() {}
  
  public UIObject(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  public boolean isVisible() {
    return visible;
  }

  public UIObject setVisible(boolean visible) {
    if (visible != this.visible) {
      this.visible = visible;
      redraw();
    }
    return this;
  }

  public final UIObject setPosition(float x, float y) {
    this.x = x;
    this.y = y;
    redraw();
    return this;
  }
  
  public final UIObject setSize(float w, float h) {
    this.w = w;
    this.h = h;
    redraw();
    return this;
  }

  public final UIObject addToContainer(UIContainer c) {
    c.children.add(this);
    this.parent = c;
    return this;
  }
  
  public final UIObject removeFromContainer(UIContainer c) {
    c.children.remove(this);
    this.parent = null;
    return this;
  }
  
  public final UIObject redraw() {
    _redraw();
    UIObject p = this.parent;
    while (p != null) {
      p.childNeedsRedraw = true;
      p = p.parent;
    }
    return this;
  }
  
  private final void _redraw() {
    needsRedraw = true;
    for (UIObject child : children) {
      childNeedsRedraw = true;
      child._redraw();
    }    
  }
    
  public final void draw(PGraphics pg) {
    if (!visible) {
      return;
    }
    if (needsRedraw) {
      needsRedraw = false;
      onDraw(pg);
    }
    if (childNeedsRedraw) {
      childNeedsRedraw = false;
      for (UIObject child : children) {
        if (needsRedraw || child.needsRedraw || child.childNeedsRedraw) {
          pg.pushMatrix();
          pg.translate(child.x, child.y);
          child.draw(pg);
          pg.popMatrix();
        }
      }
    }
  }
  
  public final boolean contains(float x, float y) {
    return
      (x >= this.x && x < (this.x + this.w)) &&
      (y >= this.y && y < (this.y + this.h));
  }
  
  protected void onDraw(PGraphics pg) {}
  protected void onMousePressed(float mx, float my) {}
  protected void onMouseReleased(float mx, float my) {}
  protected void onMouseDragged(float mx, float my, float dx, float dy) {}  
  protected void onMouseWheel(float mx, float my, float dx) {}  
}

public class UIContainer extends UIObject {
  
  private UIObject focusedChild = null;
  
  public UIContainer() {}
  
  public UIContainer(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  public UIContainer(UIObject[] children) {
    for (UIObject child : children) {
      child.addToContainer(this);
    }
  }
  
  protected void onMousePressed(float mx, float my) {
    for (int i = children.size() - 1; i >= 0; --i) {
      UIObject child = children.get(i);
      if (child.contains(mx, my)) {
        child.onMousePressed(mx - child.x, my - child.y);
        focusedChild = child;
        break;
      }
    }
  }
    
  protected void onMouseReleased(float mx, float my) {
    if (focusedChild != null) {
      focusedChild.onMouseReleased(mx - focusedChild.x, my - focusedChild.y);
    }
    focusedChild = null;
  }
  
  protected void onMouseDragged(float mx, float my, float dx, float dy) {
    if (focusedChild != null) {
      focusedChild.onMouseDragged(mx - focusedChild.x, my - focusedChild.y, dx, dy);
    }
  }
  
  protected void onMouseWheel(float mx, float my, float delta) {
    for (UIObject child : children) {
      if (child.contains(mx, my)) {
        child.onMouseWheel(mx - child.x, mx - child.y, delta);
      }
    }
  }
  
}

public class UIContext extends UIContainer {
  
  final public PGraphics pg;
  
  UIContext(float x, float y, float w, float h) {
    super(x, y, w, h);
    pg = createGraphics((int)w, (int)h, JAVA2D);
    pg.smooth();
  }
  
  public void draw() {
    if (!visible) {
      return;
    }
    if (needsRedraw || childNeedsRedraw) {
      pg.beginDraw();
      draw(pg);
      pg.endDraw();
    }
    image(pg, x, y);
  }
  
  private float px, py;
  private boolean dragging = false;
  
  public boolean mousePressed(float mx, float my) {
    if (!visible) {
      return false;
    }
    if (contains(mx, my)) {
      dragging = true;
      px = mx;
      py = my;
      onMousePressed(mx - x, my - y);
      return true;
    }
    return false;
  }
  
  public boolean mouseReleased(float mx, float my) {
    if (!visible) {
      return false;
    }
    dragging = false;
    onMouseReleased(mx - x, my - y);
    return true;
  }
  
  public boolean mouseDragged(float mx, float my) {
    if (!visible) {
      return false;
    }
    if (dragging) {
      float dx = mx - px;
      float dy = my - py;
      onMouseDragged(mx - x, my - y, dx, dy);
      px = mx;
      py = my;
      return true;
    }
    return false;
  }
  
  public boolean mouseWheel(float mx, float my, float delta) {
    if (!visible) {
      return false;
    }
    if (contains(mx, my)) {
      onMouseWheel(mx - x, my - y, delta);
      return true;
    }
    return false;
  }
}

public class UIWindow extends UIContext {
  
  protected final static int titleHeight = 24;
  
  public UIWindow(String label, float x, float y, float w, float h) {
    super(x, y, w, h);
    new UILabel(6, 8, w-6, titleHeight-8) {
      protected void onMouseDragged(float mx, float my, float dx, float dy) {
        parent.x = constrain(parent.x + dx, 0, width - w);
        parent.y = constrain(parent.y + dy, 0, height - h);
      }
    }.setLabel(label).setFont(defaultTitleFont).addToContainer(this);
  }

  protected void onDraw(PGraphics pg) {
    pg.noStroke();
    pg.fill(#444444);
    pg.stroke(#292929);
    pg.rect(0, 0, w-1, h-1);
  }
}

public class UILabel extends UIObject {
  
  private PFont font = defaultTitleFont;
  private color fontColor = #CCCCCC;
  private String label = "";
    
  public UILabel(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  protected void onDraw(PGraphics pg) {
    pg.textAlign(LEFT, TOP);
    pg.textFont(font);
    pg.fill(fontColor);
    pg.text(label, 0, 0);
  }
  
  public UILabel setFont(PFont font) {
    this.font = font;
    redraw();
    return this;
  }
  
  public UILabel setFontColor(color fontColor) {
    this.fontColor = fontColor;
    redraw();
    return this;
  }
  
  public UILabel setLabel(String label) {
    this.label = label;
    redraw();
    return this;
  }
}

public class UICheckbox extends UIButton {
  
  private boolean firstDraw = true;
  
  public UICheckbox(float x, float y, float w, float h) {
    super(x, y, w, h);
    setMomentary(false);
  }
  
  public void onDraw(PGraphics pg) {
    pg.stroke(borderColor);
    pg.fill(active ? activeColor : inactiveColor);
    pg.rect(0, 0, h, h);
    if (firstDraw) {
      pg.fill(labelColor);
      pg.textFont(defaultItemFont);
      pg.textAlign(LEFT, CENTER);
      pg.text(label, h + 4, h/2);
      firstDraw = false;
    }
  }
      
}

public class UIButton extends UIObject {

  protected boolean active = false;
  protected boolean isMomentary = false;
  protected color borderColor = #666666;
  protected color inactiveColor = #222222;
  protected color activeColor = #669966;
  protected color labelColor = #999999;
  protected String label = "";
   
  public UIButton(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  public UIButton setMomentary(boolean momentary) {
    isMomentary = momentary;
    return this;
  }
  
  protected void onDraw(PGraphics pg) {
    pg.stroke(borderColor);
    pg.fill(active ? activeColor : inactiveColor);
    pg.rect(0, 0, w, h);
    if (label != null && label.length() > 0) {
      pg.fill(active ? #FFFFFF : labelColor);
      pg.textFont(defaultItemFont);
      pg.textAlign(CENTER);
      pg.text(label, w/2, h-5);
    }
  }
  
  protected void onMousePressed(float mx, float my) {
    if (isMomentary) {
      setActive(true);
    } else {
      setActive(!active);
    }
  }
  
  protected void onMouseReleased(float mx, float my) {
    if (isMomentary) {
      setActive(false);
    }
  }
  
  public boolean isActive() {
    return active;
  }
  
  public UIButton setActive(boolean active) {
    this.active = active;
    onToggle(active);
    redraw();
    return this;
  }
  
  public UIButton toggle() {
    return setActive(!active);
  }
  
  protected void onToggle(boolean active) {}
  
  public UIButton setBorderColor(color borderColor) {
    if (this.borderColor != borderColor) {
      this.borderColor = borderColor;
      redraw();
    }
    return this;
  }
  
  public UIButton setActiveColor(color activeColor) {
    if (this.activeColor != activeColor) {
      this.activeColor = activeColor;
      if (active) {
        redraw();
      }
    }
    return this;
  }
  
  public UIButton setInactiveColor(color inactiveColor) {
    if (this.inactiveColor != inactiveColor) {
      this.inactiveColor = inactiveColor;
      if (!active) {
        redraw();
      }
    }
    return this;
  }
  
  public UIButton setLabelColor(color labelColor) {
    if (this.labelColor != labelColor) {
      this.labelColor = labelColor;
      redraw();
    }
    return this;
  }

  public UIButton setLabel(String label) {
    if (!this.label.equals(label)) {
      this.label = label;
      redraw();
    }
    return this;
  }
  
  public void onMousePressed() {
    setActive(!active);
  }
}

public class UIToggleSet extends UIObject {

  private String[] options;
  private int[] boundaries;
  private String value;
  
  public UIToggleSet(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  public UIToggleSet setOptions(String[] options) {
    this.options = options;
    boundaries = new int[options.length];
    int totalLength = 0;
    for (String s : options) {
      totalLength += s.length();
    }
    int lengthSoFar = 0;
    for (int i = 0; i < options.length; ++i) {
      lengthSoFar += options[i].length();
      boundaries[i] = (int) (lengthSoFar * w / totalLength);
    }
    value = options[0];
    redraw();
    return this;
  }
  
  public String getValue() {
    return value;
  }
  
  public UIToggleSet setValue(String option) {
    value = option;
    onToggle(value);
    redraw();
    return this;
  }
  
  public void onDraw(PGraphics pg) {
    pg.stroke(#666666);
    pg.fill(#222222);
    pg.rect(0, 0, w, h);
    for (int b : boundaries) {
      pg.line(b, 1, b, h-1);
    }
    pg.noStroke();
    pg.textAlign(CENTER);
    pg.textFont(defaultItemFont);
    int leftBoundary = 0;
    
    for (int i = 0; i < options.length; ++i) {
      boolean isActive = options[i] == value;
      if (isActive) {
        pg.fill(lightGreen);
        pg.rect(leftBoundary + 1, 1, boundaries[i] - leftBoundary - 1, h-1);
      }
      pg.fill(isActive ? #FFFFFF : #999999);
      pg.text(options[i], (leftBoundary + boundaries[i]) / 2., h-6);
      leftBoundary = boundaries[i];
    }
  }
  
  public void onMousePressed(float mx, float my) {
    for (int i = 0; i < boundaries.length; ++i) {
      if (mx < boundaries[i]) {
        setValue(options[i]);
        break;
      }
    }
  }
  
  protected void onToggle(String option) {}
  
}


public abstract class UIParameterControl extends UIObject implements LXParameter.Listener {
  protected LXParameter parameter = null;
    
  protected UIParameterControl(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  public void onParameterChanged(LXParameter parameter) {
    redraw();
  }
  
  public UIParameterControl setParameter(LXParameter parameter) {
    if (this.parameter != null) {
      if (this.parameter instanceof LXListenableParameter) {
        ((LXListenableParameter)this.parameter).removeListener(this);
      }
    }
    this.parameter = parameter;
    if (this.parameter != null) {
      if (this.parameter instanceof LXListenableParameter) {
        ((LXListenableParameter)this.parameter).addListener(this);
      }
    }
    redraw();
    return this;
  }
}

public class UIParameterKnob extends UIParameterControl {
  private int knobSize = 28;
  private final float knobIndent = .4;  
  private final int knobLabelHeight = 14;
    
  public UIParameterKnob(float x, float y) {
    this(x, y, 0, 0);
    setSize(knobSize, knobSize + knobLabelHeight);
  }
  
  public UIParameterKnob(float x, float y, float w, float h) {
    super(x, y, w, h);
  }

  protected void onDraw(PGraphics pg) {    
    float knobValue = (parameter != null) ? parameter.getValuef() : 0;
    
    pg.ellipseMode(CENTER);
    pg.noStroke();

    pg.fill(bgGray);
    pg.rect(0, 0, knobSize, knobSize);

    // Full outer dark ring
    pg.fill(#222222);    
    pg.arc(knobSize/2, knobSize/2, knobSize, knobSize, HALF_PI + knobIndent, HALF_PI + knobIndent + (TWO_PI-2*knobIndent));

    // Light ring indicating value
    pg.fill(lightGreen);
    pg.arc(knobSize/2, knobSize/2, knobSize, knobSize, HALF_PI + knobIndent, HALF_PI + knobIndent + knobValue*(TWO_PI-2*knobIndent));
    
    // Center circle of knob
    pg.fill(#333333);
    pg.ellipse(knobSize/2, knobSize/2, knobSize/2, knobSize/2);

    String knobLabel = (parameter != null) ? parameter.getLabel() : null;
    if (knobLabel == null) {
      knobLabel = "-";
    } else if (knobLabel.length() > 4) {
      knobLabel = knobLabel.substring(0, 4);
    }
    pg.fill(#000000);
    pg.rect(0, knobSize + 2, knobSize, knobLabelHeight - 2);
    pg.fill(#999999);
    pg.textAlign(CENTER);
    pg.textFont(defaultTitleFont);
    pg.text(knobLabel, knobSize/2, knobSize + knobLabelHeight - 2);
  }
  
  public void onMouseDragged(float mx, float my, float dx, float dy) {
    if (parameter != null) {
      float value = constrain(parameter.getValuef() - dy / 100., 0, 1);
      parameter.setValue(value);
    }
  }
}

public class UIParameterSlider extends UIParameterControl {
  
  private static final float handleWidth = 12;
  
  UIParameterSlider(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  protected void onDraw(PGraphics pg) {
    pg.noStroke();
    pg.fill(#333333);
    pg.rect(0, 0, w, h);
    pg.fill(#222222);
    pg.rect(4, h/2-2, w-8, 4);
    pg.fill(#666666);
    pg.stroke(#222222);
    pg.rect((int) (4 + parameter.getValuef() * (w-8-handleWidth)), 4, handleWidth, h-8);
  }
  
  private boolean editing = false;
  private long lastClick = 0;
  private float doubleClickMode = 0;
  private float doubleClickX = 0;
  protected void onMousePressed(float mx, float my) {
    long now = millis();
    float handleLeft = 4 + parameter.getValuef() * (w-8-handleWidth);
    if (mx >= handleLeft && mx < handleLeft + handleWidth) {
      editing = true;
    } else {
      if ((now - lastClick) < 300 && abs(mx - doubleClickX) < 3) {
        parameter.setValue(doubleClickMode);  
      }
      doubleClickX = mx;
      if (mx < w*.25) {
        doubleClickMode = 0;
      } else if (mx > w*.75) {
        doubleClickMode = 1;
      } else {
        doubleClickMode = 0.5;
      }
    }
    lastClick = now;
  }
  
  protected void onMouseReleased(float mx, float my) {
    editing = false;
  }
  
  protected void onMouseDragged(float mx, float my, float dx, float dy) {
    if (editing) {
      parameter.setValue(constrain((mx - handleWidth/2. - 4) / (w-8-handleWidth), 0, 1));
    }
  }
}

public class UIScrollList extends UIObject {

  private List<ScrollItem> items = new ArrayList<ScrollItem>();

  private PFont itemFont = defaultItemFont;
  private int itemHeight = 20;
  private color selectedColor = lightGreen;
  private color pendingColor = lightBlue;
  private int scrollOffset = 0;
  private int numVisibleItems = 0;

  private boolean hasScroll;
  private float scrollYStart;
  private float scrollYHeight;
  
  public UIScrollList(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
    
  protected void onDraw(PGraphics pg) {
    int yp = 0;
    boolean even = true;
    for (int i = 0; i < numVisibleItems; ++i) {
      if (i + scrollOffset >= items.size()) {
        break;
      }
      ScrollItem item = items.get(i + scrollOffset);
      color itemColor;
      color labelColor = #FFFFFF;
      if (item.isSelected()) {
        itemColor = selectedColor;
      } else if (item.isPending()) {
        itemColor = pendingColor;
      } else {
        labelColor = #000000;
        itemColor = #707070;
      }
      float factor = even ? .92 : 1.08;
      itemColor = color(hue(itemColor), saturation(itemColor), min(100, factor*brightness(itemColor)));
      
      pg.noStroke();
      pg.fill(itemColor);
      pg.rect(0, yp, w, itemHeight);
      pg.fill(labelColor);
      pg.textFont(itemFont);
      pg.textAlign(LEFT, TOP);
      pg.text(item.getLabel(), 6, yp+4);
                  
      yp += itemHeight;
      even = !even;
    }
    if (hasScroll) {
      pg.noStroke();
      pg.fill(color(0, 0, 100, 15));
      pg.rect(w-12, 0, 12, h);
      pg.fill(#333333);
      pg.rect(w-12, scrollYStart, 12, scrollYHeight);
    }
    
  }
  
  private boolean scrolling = false;
  private ScrollItem pressedItem = null;
  
  public void onMousePressed(float mx, float my) {
    pressedItem = null;
    if (hasScroll && mx >= w-12) {
      if (my >= scrollYStart && my < (scrollYStart + scrollYHeight)) {
        scrolling = true;
        dAccum = 0;
      }
    } else {
      int index = (int) my / itemHeight;
      if (scrollOffset + index < items.size()) {
        pressedItem = items.get(scrollOffset + index);
        pressedItem.onMousePressed();
        redraw();
      }
    }
  }
  
  public void onMouseReleased(float mx, float my) {
    scrolling = false;
    if (pressedItem != null) {
      pressedItem.onMouseReleased();
      redraw();
    }    
  }
  
  private float dAccum = 0;
  public void onMouseDragged(float mx, float my, float dx, float dy) {
    if (scrolling) {
      dAccum += dy;
      float scrollOne = h / items.size();
      int offset = (int) (dAccum / scrollOne);
      if (offset != 0) {
        dAccum -= offset * scrollOne;
        setScrollOffset(scrollOffset + offset);
      }
    }
  }
    
  private float wAccum = 0;
  public void onMouseWheel(float mx, float my, float delta) {
    wAccum += delta;
    int offset = (int) (wAccum / 5);
    if (offset != 0) {
      wAccum -= offset * 5;
      setScrollOffset(scrollOffset + offset);
    }
  }
  
  public void setScrollOffset(int offset) {
    scrollOffset = constrain(offset, 0, items.size() - numVisibleItems);
    scrollYStart = round(scrollOffset * h / items.size());
    scrollYHeight = round(numVisibleItems * h / items.size());
    redraw();
  }
  
  public UIScrollList setItems(List<ScrollItem> items) {
    this.items = items;
    numVisibleItems = (int) (h / itemHeight);
    hasScroll = items.size() > numVisibleItems;
    setScrollOffset(0);
    redraw();
    return this;
  }
}

public interface ScrollItem {
  public boolean isSelected();
  public boolean isPending();
  public String getLabel();
  public void onMousePressed();
  public void onMouseReleased();  
}

public abstract class AbstractScrollItem implements ScrollItem {
  public boolean isPending() {
    return false;
  }
  public void select() {}
  public void onMousePressed() {}
  public void onMouseReleased() {}
}

public class UIIntegerBox extends UIObject {
  
  private int minValue = 0;
  private int maxValue = MAX_INT;
  private int value = 0;
  
  UIIntegerBox(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  public UIIntegerBox setRange(int minValue, int maxValue) {
    this.minValue = minValue;
    this.maxValue = maxValue;
    setValue(constrain(value, minValue, maxValue));
    return this;
  }
  
  protected void onDraw(PGraphics pg) {
    pg.stroke(#666666);
    pg.fill(#222222);
    pg.rect(0, 0, w, h);
    pg.textAlign(CENTER, CENTER);
    pg.textFont(defaultItemFont);
    pg.fill(#999999);
    pg.text("" + value, w/2, h/2);
  }
  
  protected void onValueChange(int value) {}
  
  float dAccum = 0;
  protected void onMousePressed(float mx, float my) {
    dAccum = 0;
  }
  
  protected void onMouseDragged(float mx, float my, float dx, float dy) {
    dAccum -= dy;
    int offset = (int) (dAccum / 5);
    dAccum = dAccum - (offset * 5);
    setValue(value + offset);
  }
  
  public int getValue() {
    return value;
  }
  
  public UIIntegerBox setValue(int value) {
    if (this.value != value) {
      int range = (maxValue - minValue + 1);
      while (value < minValue) {
        value += range;
      }        
      this.value = minValue + (value - minValue) % range;
      this.onValueChange(this.value);
      redraw();
    }
    return this;
  }
}
