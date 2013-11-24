class XYZPixel extends SCPattern
{
	float xm = model.xMin;
	float ym = model.yMin;
	float zm = model.zMin;

	float cubeWidth = 35;
	float xm2 = model.xMin+cubeWidth;
	float ym2 = model.yMin+cubeWidth;
	float zm2 = model.zMin+cubeWidth;

	XYZPixel(GLucose glucose) {
		super(glucose);
		//myP = new LXPoint(20,20,20);
	}

	void run(double deltaMs)
	{
		for(LXPoint p : model.points)
		{
			if(p.x > xm && p.x<= xm2 && p.y > ym && p.y<= xm2 && p.z<= zm2 && p.z > zm)
			{
				colors[p.index] = lx.hsb(lx.getBaseHue()+100, 100, 100);
		        
			}else{
				colors[p.index] = 0;
			}
		}
		float minIS=min(model.xMax,model.yMax,model.zMax);
		xm = (xm + 1 ) % minIS;
		ym = (ym + 1 ) % minIS;
		zm = (zm + 1 ) % minIS;

		xm2 = xm + cubeWidth;
		ym2 = ym2 + cubeWidth;
		zm2 = zm2 + cubeWidth;
	}
}

class MultipleCubes extends SCPattern
{
	float xm = model.xMin;
	float ym = model.yMin+10;
	float zm = model.zMin+5;

	float xma = model.xMin;
	float xmb = model.xMin;

	float cubeWidth = 35;

	float minIS;

	MultipleCubes(GLucose glucose) {
		super(glucose);
		minIS = 200;
	}

	void drawVirtualCube(float bottomX, float bottomY, float bottomZ, float side, int cubeColor)
	{
		for(LXPoint p : model.points)
		{
			if(p.x > bottomX && p.x<= bottomX+side && p.y > bottomY && p.y<= bottomY + side  && p.z > bottomZ &&  p.z<= bottomZ+side)
			{
				colors[p.index] = cubeColor;
			}
		}
	}

	void clear()
	{
		for(int i=0;i<colors.length;i++)
		{
			colors[i]=0;
		}
	}
	float side = 29.0;
	int col;
	int hueDo;
	void run(double deltaMs)
	{
		boolean up = false;
		clear();
		for(int i = 0;i < model.yMax / side; i++)
		{
			//println(Math.abs(minIS - xm - 30*(i % 3) - xm + 30*(i % 3)));
			if(i % 2 ==0)
			{
				xm = xma;
			}else{
				xm = xmb;
			}
			if(Math.abs(minIS - xm - 30*(i % 3) - xm + 30*(i % 3)) < side * 1.5)
			{
				hueDo = (hueDo+1) % 255;
				up = true;
			}
			col =  lx.hsb(lx.getBaseHue() + hueDo,100,100);
			drawVirtualCube(minIS-xm- 30*(i % 3), ym+i*side, zm, side, col);
			drawVirtualCube(xm + 30*(i % 3), ym+i*side, zm, side, col);
		}
		
		xma = (xma + 7 ) % minIS;
		xmb = (xmb + 3) % minIS;
		//ym = (ym + 1 ) % minIS;
		//zm = (zm + 1 ) % minIS;
	}
}

class TowerParams extends SCPattern
{
	BasicParameter hueoff = new BasicParameter("Hueoff", 0.0);
	BasicParameter hueSpan = new BasicParameter("HueRange", 0.0);
	BasicParameter t1 = new BasicParameter("T1", 0.0);
	BasicParameter t2 = new BasicParameter("T2", 0.0);
	BasicParameter t3 = new BasicParameter("T3", 0.0);
	BasicParameter t4 = new BasicParameter("T4", 0.0);
	BasicParameter t5 = new BasicParameter("T5", 0.0);
	BasicParameter t6 = new BasicParameter("T6", 0.0);
	BasicParameter t7 = new BasicParameter("T7", 0.0);
	BasicParameter t8 = new BasicParameter("T8", 0.0);
	BasicParameter t9 = new BasicParameter("T9", 0.0);
	BasicParameter t10 = new BasicParameter("T10", 0.0);
	BasicParameter t11 = new BasicParameter("T11", 0.0);
	BasicParameter t12 = new BasicParameter("T12", 0.0);
	BasicParameter t13 = new BasicParameter("T13", 0.0);
	BasicParameter t14 = new BasicParameter("T14", 0.0);
	BasicParameter t15 = new BasicParameter("T15", 0.0);
	BasicParameter t16 = new BasicParameter("T16", 0.0);

	ArrayList<BasicParameter> towerParams;
	int towerSize;
	int colorSpan;
	TowerParams(GLucose glucose) {
		super(glucose);

		towerParams = new ArrayList<BasicParameter>();
		addParameter(hueoff);
		addParameter(hueSpan);
		towerParams.add(t1);
		towerParams.add(t2);
		towerParams.add(t3);
		towerParams.add(t4);
		towerParams.add(t5);
		towerParams.add(t6);
		towerParams.add(t7);
		towerParams.add(t8);
		towerParams.add(t9);
		towerParams.add(t10);
		towerParams.add(t11);
		towerParams.add(t12);
		towerParams.add(t13);
		towerParams.add(t14);
		towerParams.add(t15);
		towerParams.add(t16);
		for(BasicParameter p : towerParams)
		{
			addParameter(p);
		}
		towerSize = model.towers.size();
		colorSpan = 255 / towerSize;
	}

	void run(double deltaMs)
	{
		clearALL();
		Tower t;
		for(int i=0; i<towerSize ;i++)
		{	
			t= model.towers.get(i);
			for(LXPoint p : t.points)
			{
				if(p.y<towerParams.get(i).getValuef()*200)
				{
					colors[p.index]=lx.hsb(255 * hueoff.getValuef()+colorSpan * hueSpan.getValuef() * i, 255, 255);
				}
			}
		}

	}

	public void clearALL()
	{
		for(LXPoint p : model.points)
		{
			colors[p.index] = 0;
		}
	}

}
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
	
	public void run(double deltaMs) {
		

		if(counter % 10 ==0)
		{
			doDraw(c,0);
			c = (c + 1) % towerrange;
			long col = lx.hsb(Math.round(Math.random()*255),255,255) ;
			doDraw(c,col);
		}
		counter++;

	}

	public void doDraw(int c,long col)
	{
			Tower t= model.towers.get((int) c);
			for(LXPoint p : t.points)
			{
				colors[p.index] = (int) col;
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
	public void run(double deltaMs) 
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
	public void run(double deltaMs) 
	{
		clearALL();
		super.run(deltaMs);
		Graphic randomsGraphic = getGraphicByName("myRandoms");
		randomsGraphic.position = Math.round(sin(count)*1000)+5000;
		count+= 0.005;
	}
	public void clearALL()
	{
		for(LXPoint p : model.points)
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
