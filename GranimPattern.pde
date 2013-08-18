class Graphic
{
	public int position  = 0;
	public ArrayList<Integer> graphicBuffer;

	Graphic()
	{	
		graphicBuffer = new ArrayList<Integer>();
	}

	
};
class GranimPattern extends SCPattern
{
	ArrayList<Graphic> displayList;

	GranimPattern(GLucose glucose)
	{
		super(glucose);
		displayList = new ArrayList<Graphic>();
	}

	public void addGraphic(Graphic g)
	{
		displayList.add(g);
	}

	public void run(int deltaMs) 
	{
		for(Graphic g : displayList)
		{
			List<Point> drawList = model.points.subList(g.position, g.position + g.graphicBuffer.size());

			for (int i=0; i < drawList.size(); i++)
			{
				colors[drawList.get(i).index] = (int) g.graphicBuffer.get(i);
			}
		}
	}

};

class RedThreeGraphic extends Graphic
{
	RedThreeGraphic()
	{
		super();
		prepare();
	}
	public void prepare()
	{
		for(int i=0; i < 3 ;i++)
		{
			graphicBuffer.add(color(0,255,255));
		}
	}
};
