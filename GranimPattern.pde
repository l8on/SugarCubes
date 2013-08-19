import java.util.LinkedHashMap;
class Graphic
{
	public boolean changed = false;
	public int position  = 0;
	public ArrayList<Integer> graphicBuffer;
	Graphic()
	{	
		graphicBuffer = new ArrayList<Integer>();
	}
	public int width()
	{
		return graphicBuffer.size();
	}

	
};
class Granim extends Graphic
{
	HashMap<String,Graphic> displayList;
	
	Granim()
	{
		displayList = new HashMap<String,Graphic>();
	}
	public Graphic addGraphic(String name, Graphic g)
	{
		while(width()< g.position+1)
		{
				graphicBuffer.add(color(0,0,0));
		}
		drawAll();
		displayList.put(name , g);
		changed =true;
		return g;
	}

	public Graphic getGraphicByName(String name)
	{
		return displayList.get(name);
	}

	public void update()
	{
		
		for(Graphic g : displayList.values())
		{
			if(g instanceof Granim)
			{
				((Granim) g).update();
				
			}
			changed = changed || g.changed;
			if(changed)
			{
				while(width()< g.position + g.width())
				{
					graphicBuffer.add(color(0,0,0));
				}
				if(g.changed)
				{
					drawOne(g);
					g.changed =false;
				}
			}
		}
		changed = false;

	}
	public void drawOne(Graphic g)
	{
		graphicBuffer.addAll(g.position,g.graphicBuffer);
	}
	public void drawAll()
	{
	}
};
class GranimPattern extends SCPattern
{
	HashMap<String,Graphic> displayList;

	GranimPattern(GLucose glucose)
	{
		super(glucose);
		displayList = new HashMap<String,Graphic>();
	}

	public Graphic addGraphic(String name, Graphic g)
	{
		displayList.put(name,g);
		return g;
	}

	public Graphic getGraphicByName(String name)
	{
		return displayList.get(name);
	}

	public void run(int deltaMs) 
	{
		drawToPointList();
	}
	private Integer[] gbuffer;
	public void drawToPointList()
	{
		for(Graphic g : displayList.values())
		{
			if(g instanceof Granim)
			{
				((Granim) g).update();
			}
			List<Point> drawList = model.points.subList(Math.min(g.position,colors.length-1), Math.min(g.position + g.width(),colors.length-1));
			println("drawlistsize "+drawList.size());
			
			gbuffer = g.graphicBuffer.toArray(new Integer[0]);
			
			for (int i=0; i < drawList.size(); i++)
			{
				colors[drawList.get(i).index] = gbuffer[i];
			}
			g.changed =false;
		}
	}

};

class RedsGraphic extends Graphic
{
	RedsGraphic()
	{
		super();
		drawit(10);
	}
	RedsGraphic(int len)
	{
		super();
		drawit(len);
		
	}
	void drawit(int len)
	{
		for(int i = 0; i < len ;i++)
		{
			graphicBuffer.add(color(0,255,255));
		}
	}
};

class RedsGranim extends Granim
{
	RedsGranim()
	{
		super();
		addGraphic("myreds", new RedsGraphic(10));
	}
	RedsGranim(int len)
	{
		super();
		addGraphic("myreds", new RedsGraphic(len));
	}
	public float count = 0.0;
	public void update()
	{
		Graphic g=getGraphicByName("myreds");
		g.position = Math.round(sin(count)*20)+100;
		count+= 0.1;
		if(count>Math.PI*2)
		{
			count=0;
		}
		super.update();
	}
	
};

class RandomsGranim extends Granim
{
	private int _len =0 ;
	RandomsGranim()
	{
		super();
		_len =100;
		addGraphic("myrandoms", makeGraphic(_len));
	}
	RandomsGranim(int len)
	{
		super();
		_len=len;
		addGraphic("myrandoms", makeGraphic(len));
	}
	public Graphic makeGraphic(int len)
	{
		int[] colors= new int[len]; 
		for(int i =0;i<len;i++)
		{
			colors[i]=(int) Math.round(Math.random()*255);
		}
		return new ColorDotsGraphic(colors);
	}
	private int count =1;
	private int instanceCount =0;
	public void update()
	{
		super.update();
		if(instanceCount<50 && count % 20==0)
		{
			instanceCount++;
			Graphic h=addGraphic("myrandoms_"+instanceCount, makeGraphic(_len));
			h.position = instanceCount*(_len+100);
			println("one more " + instanceCount+" at "+h.position);
			count=0;
			changed = true;
		}
		count++;
		
	}
	
};


class ColorDotsGraphic extends Graphic
{
	ColorDotsGraphic(int[] colorSequence)
	{
		super();
		for (int colorVal : colorSequence)
		{
			graphicBuffer.add(color(colorVal, 255, 255));
		}
		changed = true;
	}
};
