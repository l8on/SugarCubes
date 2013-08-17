class Sandbox extends SCPattern
{

	LetsTry(GLucose glucose) {
		super(glucose);
	}
	int c=0;
	int huerange=255;
	int cuberange = 74;

	int counter=0;
	public void run(int deltaMs) {
		Cube cube = model.cubes.get((int) c);
		println("face length "+cube.faces.size());
		if(cube.faces.size()!=4)
		{
			for(Face f : cube.faces)
			{
			double col = Math.random()*255;
				for(Point p: f.points)
				{
					colors[p.index] = color(Math.round(col),255,255);
				}
			}
				
			
		}
		if(counter% 3 ==0)
		{
			c = (c+1) % cuberange;
		}
		counter++;
		println(c);
	}
}