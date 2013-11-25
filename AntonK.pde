/**************************************************************
 * WORKING PATTERNS
 **************************************************************/

class AKPong extends SCPattern
{
    private final BasicParameter speed = new BasicParameter("Speed", 0);
    private final BasicParameter leftKnob = new BasicParameter("Left", 0.5);
    private final BasicParameter rightKnob = new BasicParameter("Right", 0.5);
    private final float R = 20;
    private final float W = 20;
    private final float H = 80;
    private final float PADDLE_STEP = 5;
    private float oldLeft = leftKnob.getValuef();
    private float oldRight = rightKnob.getValuef();
        
    private Paddle left = new Paddle(model.xMin, model.cy - H / 2, model.xMin + W, model.cy + H / 2);
    private Paddle right = new Paddle(model.xMax - W, model.cy - H / 2, model.xMax, model.cy + H / 2);
    private Ball ball = new Ball();
    
    class Paddle
    {
        float x1, y1, x2, y2;
        public Paddle(float x1, float y1, float x2, float y2)
        { this.x1 = x1; this.y1 = y1; this.x2 = x2; this.y2 = y2; }
        public boolean contains(LXPoint p)
        { return p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2; }
        public void moveUp()
        {
            float adj = 9 * speed.getValuef();
            if (y2 + PADDLE_STEP < model.yMax)
            {
                y1 += PADDLE_STEP + adj;
                y2 += PADDLE_STEP + adj;
            }
            else
            {
                y1 = model.yMax - H;
                y2 = model.yMax;
            }
        }
        public void moveDown()
        {
            float adj = 15 * speed.getValuef();
            if (y2 - PADDLE_STEP > model.yMin)
            {
                y1 -= PADDLE_STEP + adj;
                y2 -= PADDLE_STEP + adj;
            }
            else
            {
                y1 = model.yMin;
                y2 = model.yMin + H;
            }
        }
        
        public void moveTo(float y)
        {
            y1 = (model.yMax - H) * y;
            y2 = (model.yMax * y + H *(1 - y));
        }
    }
    
    class Ball
    {
        float x = model.cx, y = model.cy, z = model.cz;
        int xDir = 1, yDir = 1;
        int c = 0;
        public boolean contains(LXPoint p)
        { return sqrt(sq(p.x - ball.x) + sq(p.y - y) + sq(p.z - z)) < R; }
        public boolean step()
        {
            ++c;
            if (c > 360)
                c = 0;

            // Collision with floor/ceiling
            if (y + R > model.yMax || y - R < model.yMin)
                ball.yDir *= -1;
            // Collision with right wall
            if (x + R > model.xMax)
            {
                // Check if paddle is here
                if (y < right.y2 && y > right.y1)
                    xDir *= -1;
                else
                    return false;
            }
            // Collision with left wall
            if (x - R < model.xMin)
            {
                // Check if paddle is here
                if (y < left.y2 && y > left.y1)
                    xDir *= -1;
                else
                    return false;
            }
            x += xDir + xDir * 9 * speed.getValuef();
            y += yDir + yDir * 9 * speed.getValuef();
            return true;
        }
    }

    public boolean noteOn(Note note)
    {
        switch (note.getPitch())
        {
            case 49:    // W -> left paddle up
                left.moveUp();
                break;
            case 50:    // S -> left paddle down
                left.moveDown();
                break;
            case 61:    // O -> right paddle up
                right.moveUp();
                break;
            case 62:    // L -> right paddle down
                right.moveDown();
                break;
        }
        return true;
    }

    public AKPong(GLucose glucose)
    {
        super(glucose);
        addParameter(speed);
        addParameter(leftKnob);
        addParameter(rightKnob);
    }
    
    public void run(double deltsMs)
    {
        float newLeft = leftKnob.getValuef();
        float newRight = rightKnob.getValuef();
        
        if (newLeft != oldLeft)
        {
            left.moveTo(newLeft);
            oldLeft = newLeft;
        }
        if (newRight != oldRight)
        {
            right.moveTo(newRight);
            oldRight = newRight;
        }
        if (! ball.step())
            ball = new Ball();
        for (LXPoint p : model.points)
        {
            if (ball.contains(p))
                colors[p.index] = lx.hsb(ball.c, 100, 100);
            else if (left.contains(p))
                colors[p.index] = lx.hsb(0, 0, 100);
            else if (right.contains(p))
                colors[p.index] = lx.hsb(0, 0, 100);
            else
                colors[p.index] = 0;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////

/**************************************************************
 * WORKS IN PROGRESS
 **************************************************************/

class AKInvader extends SCPattern
{
    private final SawLFO h = new SawLFO(0, 1, 5000);
    public AKInvader(GLucose glucose)
    {
        super(glucose);
        addModulator(h).trigger();
    }
    
    public void run(double deltaMs)
    {
        color c = lx.hsb(h.getValuef() * 360, 100, 100);
        int nTowers = model.towers.size();
        int tower = nTowers / 2;
        // tower 0
        for (int cube = 1; cube <= 3; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
        // tower 1
        ++tower;
        for (int cube = 2; cube <= 3; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
//        for (LXPoint p : model.towers.get(tower).cubes.get(5).points)
//            colors[p.index] = c;
        // tower 2
        ++tower;
        for (int cube = 1; cube <= 5; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
        // tower 3
        ++tower;
        for (LXPoint p : model.towers.get(tower).cubes.get(0).points)
            colors[p.index] = c;
        for (int cube = 2; cube <= 3; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
        for (LXPoint p : model.towers.get(tower).cubes.get(5).points)
            colors[p.index] = c;
        // tower 4
        ++tower;
        for (int cube = 2; cube <= 5; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
        // tower 5
        ++tower;
        for (LXPoint p : model.towers.get(tower).cubes.get(0).points)
            colors[p.index] = c;
        for (int cube = 2; cube <= 3; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
        for (LXPoint p : model.towers.get(tower).cubes.get(5).points)
            colors[p.index] = c;
        // tower 6
        ++tower;
        for (int cube = 1; cube <= 5; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
        // tower 7
        ++tower;
        for (int cube = 2; cube <= 3; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
//        for (LXPoint p : model.towers.get(tower).cubes.get(5).points)
//            colors[p.index] = c;
        // tower 8
        ++tower;
        for (int cube = 1; cube <= 3; ++cube)
            for (LXPoint p : model.towers.get(tower).cubes.get(cube).points)
                colors[p.index] = c;
    }
}


class AKTetris extends SCPattern
{
    // Movement increments
    private final float STEP_Y = 1;
    private final float STEP_X = 10;
    // Block dimensions
    private final float D = 10;

    private Shape shape = new Box();

    class Block
    {
        float x, y;      // Block position, lower left corner
        public Block(float x, float y)
        {
            this.x = x;
            this.y = y;
        }
    }

    abstract class Shape
    {
        List<Block> blocks;    // Blocks comprising this shape
        float x, y;            // Shape position, lower left corner
        float h, w;            // Effective Shape dimensions
        color c;
        
        public boolean contains(LXPoint p)
        {
            for (Block b : blocks)
                if (p.x > b.x && p.x < b.x + D && p.y > b.y && p.y < b.y + D)
                    return true;
            return false;
        }
        
        public void dropDown(float inc)
        {
            for (Block b : blocks)
                b.y -= inc;
            y -= inc;
        }
        
        public void moveLeft(float inc)
        {
            for (Block b : blocks)
                b.x -= inc;
            x -= inc;
        }
        
        public void moveRight(float inc)
        {
            for (Block b : blocks)
                b.x += inc;
            x += inc;
        }
    }
    
    class Box extends Shape
    {
        public Box()
        {
            /**
             * [2][3]
             * [0][1]
             * red
             */
             blocks = new LinkedList<Block>();
             blocks.add(new Block(model.cx - D, model.yMax));
             blocks.add(new Block(model.cx, model.yMax));
             blocks.add(new Block(model.cx - D, model.yMax + D));
             blocks.add(new Block(model.cx, model.yMax + D));
             w = h = 2 * D;
             c = lx.hsb(0, 100, 100);
             x = model.cx - w / 2;
             y = model.yMax;
        }
    }
    
    public AKTetris(GLucose glucose)
    {
        super(glucose);
    }
    
    public boolean noteOn(Note note)
    {
        switch (note.getPitch())
        {
            case 48:    // A -> left
                shape.moveLeft(STEP_X);
                break;
            case 52:    // D -> right
                shape.moveRight(STEP_X);
                break;
        }
        return true;
    }
    
    public void run(double deltaMs)
    {
        for (LXPoint p : model.points)
        {
            if (shape.contains(p))
                colors[p.index] = shape.c;
            else
                colors[p.index] = 0;
        }
        if (shape.y > model.yMin)
            shape.dropDown(STEP_Y);
    }
}


class AKMatrix extends SCPattern
{    
    private List<TowerStrip> towerStrips = new ArrayList<TowerStrip>(0);

    class TowerStrip
    {
        List<LXPoint> points = new ArrayList<LXPoint>(0);
    }
    
    class DXPoint
    {
        LXPoint left, right;
        public DXPoint(LXPoint left, LXPoint right)
        {
            this.left = left;
            this.right = right;
        }
    }

    public AKMatrix(GLucose glucose)
    {
        super(glucose);
//        for (Tower t : model.towers)
        {
            Tower t = model.towers.get(0);
            for (int i = 0; i < 4; ++i)
                towerStrips.add(new TowerStrip());
            
//            int i = 0;
//            for (Strip s : t.strips)
            {
                for (int i = 1; i <= 13; i += 2)
                {
                    Strip s = t.strips.get(i);
                {
                    for (LXPoint p : s.points)
                        colors[p.index] = lx.hsb(80 * (i % 4), 100, 100);
                }
                }
//                ++i;
            }
        }
    }
    
    public void run(double deltaMs)
    {
    }
}


class AKEgg extends SCPattern
{
    private final SinLFO xRadius = new SinLFO(0.01, 1, 1500);
    private final SinLFO yRadius = new SinLFO(0.01, 1, 2000);
    private final SinLFO zRadius = new SinLFO(0.01, 1, 2500);
    
    private LXPoint center;
    private float t;
    private final float X = model.xMax / 2;
    private final float Y = model.yMax / 2;
    private final float Z = model.zMax / 2;

    public AKEgg(GLucose glucose)
    {
        super(glucose);
        addModulator(xRadius).trigger();
        addModulator(yRadius).trigger();
        addModulator(zRadius).trigger();
        
        center = new LXPoint(model.cx, model.cy, model.cz);
        t = 10;
    }
    
    public void run(double deltaMs)
    {
        for (LXPoint p : model.points)
        {
            float v = sqrt(sq(p.x - center.x) + sq(p.y - center.y) + sq(p.z - center.z));
            float r = sqrt(sq(xRadius.getValuef() * X) + sq(yRadius.getValuef() * Y) + sq(zRadius.getValuef() * Z));
            if (v > r - t && v < r)
                colors[p.index] = lx.hsb(0, 0, 100);
            else
                colors[p.index] = 0;
        }
    }
}


class AKCubes extends SCPattern
{
    private Cube cube;
    private int sec;
    
    public AKCubes(GLucose glucose)
    {
        super(glucose);
        cube = model.cubes.get((int) random(model.cubes.size()));
        sec = 0;
    }


    public void run(double deltaMs)
    {
        sec += deltaMs;
        if (sec >= 1000)
        {
            for (LXPoint p : cube.points)
                colors[p.index] = 0;
            cube = model.cubes.get((int) random(model.cubes.size()));
            sec = 0;
        }
        for (LXPoint p : cube.points)
            colors[p.index] = lx.hsb(0, 0, 100);
    }
}


class AKSpiral extends SCPattern
{
    private int ms;
    public AKSpiral(GLucose glucose)
    {
        super(glucose);
        ms = 0;
    }
    
    public void run(double deltaMs)
    {
//        colors[new LXPoint(model.cx, model.cy, model.cz).index] = lx.hsb(0, 0, 100);
    }
}


class AKSpace extends SCPattern
{
    private LinkedList<Star> stars;

    class Star
    {
        // Current coordinates
        float x, y, z;
        // Ending coordinates
//        final float xEnd, yEnd, zEnd;
        // Radius
        final float r;
        // Speed
        float xInc, yInc, zInc;
        
        Star()
        {
            // Set radius
            this.r = 10;
            // Set starting coords at center
            this.reset();
        }
        
        public void reset()
        {
            this.x = model.cx;
            this.y = model.cy;
            this.z = model.zMax + this.r;
            
            // Direction of movement
            float angle = random(0, TWO_PI);
            // Calculate speed of travel
            this.xInc = cos(angle);
            this.yInc = sin(angle);
            // Star must cover full z range in the time it takes to cover dist
            this.zInc = this.z / min(abs(model.xMax * cos(angle)), abs(model.yMax * sin(angle)));
        }
        
        public void increment()
        {
            this.x += this.xInc;
            this.y += this.yInc;
            this.z -= this.zInc;
        }
        
        public boolean outOfBounds()
        {
            return (this.x > model.xMax || this.x < model.xMin || this.y > model.yMax || this.y < model.yMin);
        }
    }
    
    public AKSpace(GLucose glucose)
    {
        super(glucose);
        stars = new LinkedList<Star>();
        for (int i = 0; i < 50; ++i)
            stars.add(new Star());
    }
    
    public void run(double deltaMs)
    {
        for (LXPoint p : model.points)
            colors[p.index] = 0;

        for (Star star : stars)
        {
            if (star.x > model.xMax || star.x < model.xMin || star.y > model.yMax || star.y < model.yMin)
                star.reset();
            else
            {
                star.x += star.xInc;
                star.y += star.yInc;
                star.z -= star.zInc;
            }
            // Draw stars on model
            for (LXPoint p : model.points)
            {
                // Check if point falls within star
                if (sqrt(sq(p.x - star.x) + sq(p.y - star.y) + sq(p.z - star.z)) <= star.r)
                    colors[p.index] = lx.hsb(0, 0, 100);
            }
        }
    }
}
