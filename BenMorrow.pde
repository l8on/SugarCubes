class Sandbox extends SCPattern
{
	int c=0;
	int prevC=0;
	int huerange=255;
	int pointrange= model.points.size();
	int striprange= model.strips.size();
	int facerange= model.faces.size();
	int cuberange = model.cubes.size();
	int towerrange = model.towers.size();
	int counter=0;

	Sandbox(GLucose glucose) {
		super(glucose);
		println("points "+pointrange);
		println("strips "+striprange);
		println("faces "+facerange);
		println("cubes "+cuberange);
		println("towers "+towerrange);
	}
	
	public void run(int deltaMs) {
		

		if(counter % 10 ==0)
		{
			doDraw(c,0);
			c = (c + 1) % towerrange;
			long col = color(Math.round(Math.random()*255),255,255) ;
			doDraw(c,col);
		}
		counter++;

	}

	public void doDraw(int c,long col)
	{
			Tower t= model.towers.get((int) c);
			for(Point p : t.points)
			{
				colors[p.index] = (int) col;
			}
	}
};



class Screen extends Sandbox
{
	BasicParameter z=new BasicParameter("Z",0.0);
	BasicParameter y=new BasicParameter("y",0.0);
	BasicParameter o=new BasicParameter("o",0.0);




	Screen(GLucose glucose)
	{
		super(glucose);
		addParameter(z);
		addParameter(y);
		addParameter(o);
	}

	ArrayList<Point> buffer = new ArrayList();
	public void run(int deltaMs) {
		buffer.clear();
		for(int i=0; i<model.points.size();i++)
		{
			Point p = model.points.get(i);
			
			if(p.fz < z.getValue()*20)
			{
				colors[p.index]=color(0,255,255);
				buffer.add(p);
			}else if(p.fy > y.getValue()*100){

				colors[p.index]=color(128,255,255);
				buffer.add(p);
			}else{
				colors[p.index]=0;
			}
			
			
		}
		if(o.getValuef()>0.5)
		{
			printOutPoints((ArrayList<Point>) buffer.clone());
			o.setValue(0);
		}
	}
	void sortOutPoints(ArrayList<Point> buffer)
	{
		Collections.sort(buffer, new Comparator<Point>() {
    		public int compare(Point a, Point b)
    		{
    			return (int) (((float) b.fx) - ((float) a.fx));
    		}
		});
		print("{");
		for(Point p : buffer)
		{
			print(str(p.index)+", ");
		}
		print("}");
		
	}
	void printOutPoints(ArrayList<Point> buffer)
	{
		int[][] places = new int[300][200];
		for(Point p : buffer)
		{
			places[Math.round(p.fx)+10][Math.round(p.fy)+10] = p.index;
		}
		print("{");
		for(int j=0;j<300;j++)
		{
			print("{");
			for(int k=0;k<200;k++)
			{
				String out = (k==199) ? (str(places[j][k])) : (str(places[j][k])+", ");
				print(out);
			}
			print(j==299 ? "}" : "},\n");
		}
		print("}");
		
	}
	


};

class IterateScreen extends SCPattern
{
	BasicParameter x=new BasicParameter("x",0.0);

	IterateScreen(GLucose glucose)
	{
		super(glucose);
		addParameter(x);
	}
	ScreenPixelDump sx=new ScreenPixelDump();	

	public void run(int deltaMs)
	{
		for(int i=0;i<sx.sortedX.length;i++)
		{
			if(i<x.getValuef()*((float )sx.sortedX.length))
			{
				colors[sx.sortedX[i]]=color(0,255,255);
			}else{
				colors[sx.sortedX[i]]=0;
			}
		}
	}
};

class IterateScreen2D extends SCPattern
{
	BasicParameter x=new BasicParameter("x",0.0);
	BasicParameter y=new BasicParameter("y",0.0);
	ScreenPixelDump sx = new ScreenPixelDump();	
	int[][] data; 
	IterateScreen2D(GLucose glucose)
	{
		super(glucose);
		data = sx.twoD();
		addParameter(x);
		addParameter(y);
	}
	

	public void run(int deltaMs)
	{
		for(Point p : model.points)
		{
			colors[p.index]=0;
		}
		for(int j=0;j<x.getValuef()*300;j++)
		{
			for(int k=0;k<y.getValuef()*200;k++)
			{
				colors[data[j][k]] = color(0,255,255);
			}
		}
	}
};

class GranimTestPattern extends GranimPattern
{
	GranimTestPattern(GLucose glucose)
	{
		super(glucose);
		addGraphic("myReds",new RedsGraphic(100));
		int[] dots = {0,128,0,128,0,128,0,128,0,128,0,128};
		addGraphic("myOtherColors",new ColorDotsGraphic(dots));

		getGraphicByName("myOtherColors").position=100;
	}
	int counter=0;
	public void run(int deltaMs) 
	{
		clearALL();
		super.run(deltaMs);
		
		if(counter % 3 ==0)
		{
			Graphic reds = getGraphicByName("myReds");
			Graphic others = getGraphicByName("myOtherColors");
			reds.position = reds.position + 1 % 19000;
			others.position = others.position + 10 % 19000;
		}
	}
	public void clearALL()
	{
		for(int i = 0; i < colors.length; i++)
		{
			colors[i] = 0;
		}
	}


}

class GranimTestPattern2 extends GranimPattern
{
	GranimTestPattern2(GLucose glucose)
	{
		super(glucose);
		/*for(int i = 0;i < 100; i++)
		{
			Graphic g = addGraphic("myReds_"+i,new RedsGraphic(Math.round(Math.random() * 100)));

		}*/
		Graphic g = addGraphic("myRandoms",new RandomsGranim(50));
		g.position = 200;
		
	}
	int counter=0;
	float count=0;
	public void run(int deltaMs) 
	{
		clearALL();
		super.run(deltaMs);
		Graphic randomsGraphic = getGraphicByName("myRandoms");
		randomsGraphic.position = Math.round(sin(count)*1000)+5000;
		count+= 0.005;
	}
	public void clearALL()
	{
		for(Point p : model.points)
		{
			colors[p.index] = 0;
		}
	}


};

class DriveableCrossSections extends CrossSections
{
	BasicParameter xd; 
	BasicParameter yd;
	BasicParameter zd;
	BasicParameter mode; 

	DriveableCrossSections(GLucose glucose) {
		super(glucose);	
	}

	public void addParams()
	{
		mode = new BasicParameter("Mode", 0.0);
		xd = new BasicParameter("XD", 0.0);
		yd = new BasicParameter("YD", 0.0);
		zd = new BasicParameter("ZD", 0.0);
		addParameter(mode);
		addParameter(xd);
	    addParameter(yd);
	    addParameter(zd);

	   super.addParams();
	}

	public void onParameterChanged(LXParameter p) {
			if(p == mode)
			{
				if(interactive())
				{
					copyValuesToKnobs();
				}else{
					copyKnobsToValues();
				}
			}
	}

	void copyValuesToKnobs()
	{
		xd.setValue(x.getValue()/200);
		yd.setValue(y.getValue()/115);
		zd.setValue(z.getValue()/100);
	}

	void copyKnobsToValues()
	{
		x.setValue(xd.getValue()*200);
		y.setValue(yd.getValue()*115);
		z.setValue(zd.getValue()*100);
	}

	boolean interactive()
	{
		return Math.round(mode.getValuef())>0.5;
	}

	public void updateXYZVals()
  	{
  		if(interactive())
  		{
		  	xv = xd.getValuef()*200;
		    yv = yd.getValuef()*115;
		    zv = zd.getValuef()*100;
		}else{
			super.updateXYZVals();
			copyValuesToKnobs();
		}
  	}

}