public class _P extends BasicParameter {
	_P(String label, double value) 					{ super(label,value); 							}
	public void 	updateValue	(double value) 		{ super.updateValue(value);						}
	public float 	Val			() 					{ return getValuef();							}
	public int		Pick		(int b) 			{ return int(Val())==1 ? b-1 : int(b*Val());	} 
}

float 	c1c			(float a) 	{ return 100*constrain(a,0,1); }
float 	CalcCone	(float x1, float y1, float z1, float x2, float y2, float z2) {
						return degrees( acos ( ( x1*x2 + y1*y2 + z1*z2 ) / (sqrt(x1*x1+y1*y1+z1*z1) * sqrt(x2*x2+y2*y2+z2*z2)) ) );}
float		xMax,yMax,zMax;
float 		zTime   = random(10000);
_P 			pChoose = new _P("ANIM", 0);
//----------------------------------------------------------------------------------------------------------------------------------
class Pong extends SCPattern {
	SinLFO x,y,z,dx,dy,dz; 
	float cRad;	_P size;

	Pong(GLucose glucose) {
		super(glucose);
		xMax = model.xMax; yMax = model.yMax; zMax = model.zMax;
		cRad = xMax/15;
		addModulator(dx = new SinLFO(6000,  500, 30000	)).trigger();
		addModulator(dy = new SinLFO(3000,  500, 22472	)).trigger();
		addModulator(dz = new SinLFO(1000,  500, 18420	)).trigger();
		addModulator(x  = new SinLFO(cRad, xMax - cRad, 0)).trigger();	x.modulateDurationBy(dx);
		addModulator(y  = new SinLFO(cRad, yMax - cRad, 0)).trigger();	y.modulateDurationBy(dy);
		addModulator(z  = new SinLFO(cRad, zMax - cRad, 0)).trigger();	z.modulateDurationBy(dz);
	    addParameter(pChoose);
	    addParameter(size = new _P("SIZE", 0.4));
	}

	color Calc(float px, float py, float pz, float vx, float vy, float vz) {
		switch(pChoose.Pick(3)) {
		/*spot*/	case 0: return color(0,0,c1c(1 - CalcCone(vx-xMax/2, vy, vz-zMax/2, px-xMax/2, py, pz-zMax/2)*max(.02,.45-size.Val())));
		/*ball*/	case 1: return color(0,0,c1c(1 - dist(vx,vy,vz,px,py,pz)*.5/cRad));
		/*ballz*/	default:return color(0,0,c1c(1 - min(	dist(vx,vy,vz,px,py,pz),
															dist(vx,vy,vz,xMax-px,yMax-py,zMax-pz))*.5/cRad)); 
		}		
	}

	public void run(int deltaMs) {
		cRad = xMax*size.Val()/6;
		for (Point p : model.points) {
			colors[p.index] = Calc(p.fx, p.fy, p.fz, x.getValuef(), y.getValuef(), z.getValuef());
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
class NDat {
	float xz, yz, zz, hue, sat, speed, dir, den, contrast;
	float xoff,yoff,zoff;
	NDat (float _hue, float _sat, float _xz, float _yz, float _zz, float _con, float _den, float _speed, float _dir) {
		hue=_hue; sat=_sat; xz=_xz; yz=_yz; zz =_zz; contrast=_con; den=_den; speed=_speed; dir=_dir;
		xoff = random(100e3); yoff = random(100e3); zoff = random(100e3);
	}
}

class Noise extends SCPattern
{
	int 	CurAnim = 	-1	;
	ArrayList noises = new ArrayList();
	_P pSpeed, pMir, pBright, pContrast, pDensity, pDir;

	Noise(GLucose glucose) {
		super(glucose);									 addParameter(pChoose	);
		addParameter(pSpeed		= new _P("MPH" 	, .55)); addParameter(pMir		= new _P("MIR" 	, 0	));
		addParameter(pBright	= new _P("BRTE" ,  1 )); addParameter(pDir		= new _P("DIR" 	, 0 ));
		addParameter(pContrast	= new _P("CNTR" ,  .5)); addParameter(pDensity	= new _P("DENS" , .5));
	}

	public void run(int deltaMs) {
		zTime += deltaMs*(pSpeed.Val()-.5)*.002;
		int anim = pChoose.Pick(6);
		if (anim != CurAnim) {
			noises.clear(); CurAnim = anim; switch(anim) {
			//_hue, _sat, _xz, _yz, _zz, _con, _den, _speed, _dir
			case 0: noises.add(new NDat(0  ,0  ,100,100,200,0  ,40 ,3  ,2)); break;	// clouds
			case 1: noises.add(new NDat(0  ,0  ,75 ,75 ,150,1  ,45 ,3  ,0)); break; // drip
			case 2: noises.add(new NDat(0  ,0  ,2  ,400,2  ,1  ,40 ,3  ,0)); break;	// rain
			case 3: noises.add(new NDat(40 ,100,100,100,200,0  ,20 ,1  ,2)); 
					noises.add(new NDat(0  ,100,100,100,200,0  ,20 ,5   ,2)); break;	// fire 1
			case 4: noises.add(new NDat(0  ,100,40 ,40 ,40 ,.5 ,25 ,2.5 ,2));
					noises.add(new NDat(20 ,100,40 ,40 ,40 ,.5 ,25 ,4   ,0));
					noises.add(new NDat(40 ,100,40 ,40 ,40 ,.5 ,25 ,2   ,1));
					noises.add(new NDat(60 ,100,40 ,40 ,40 ,.5 ,25 ,3   ,3)); break; 	// machine
			case 5: noises.add(new NDat(0  ,100,400,100,2  ,1  ,20 ,3   ,2));
					noises.add(new NDat(20 ,100,400,100,2  ,1  ,20 ,2.5 ,0));
					noises.add(new NDat(40 ,400,100,100,2  ,1  ,20 ,2   ,1));
					noises.add(new NDat(60 ,400,100,100,2  ,1  ,20 ,1.5 ,3)); break; 	// spark
			default: break;
			}
		}

		for (Point p : model.points) {
			color c = color(0,0,0);
			int mir = pMir.Pick(5);

			for (int i=0;i<noises.size(); i++) { NDat n = (NDat) noises.get(i);
				float vx=p.fx, vy=p.fy, vz=p.fz;
//				if (vx > xMax/2 && (mir == 1 || mir == 3 || mir == 4)) { vx = xMax-vx; }
				if (vy > yMax/2 && (mir == 2 || mir == 3 || mir == 4)) { vy = yMax-vy; }
//				if (vz > zMax/2 && (						mir == 4)) { vz = zMax-vz; }
				float deg = radians(90*(n.dir + pDir.Pick(4)));
				float zx  = zTime * n.speed * sin(deg);
				float zy  = zTime * n.speed * cos(deg);
				float b   = noise(vx/n.xz+zx+n.xoff,vy/n.yz+zy+n.yoff,vz/n.zz+n.zoff)*1.6-.3 + n.den/100 + pDensity.Val() -1;
				float con = 1/constrain(2-n.contrast - 2*pContrast.Val(),0,1);
				b = b < .5 ? pow(b,con) : 1-pow(1-b,con);
				c = blendColor(c,color(n.hue,n.sat,c1c(b * pBright.Val())),ADD);
			}
			colors[p.index] = c;
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
