//----------------------------------------------------------------------------------------------------------------------------------
public class Pong extends DPat {
	SinLFO x,y,z,dx,dy,dz; 
	float cRad;	_DhP pSize;
	Pick  pChoose;

	Pong(GLucose glucose) {
		super(glucose);
		cRad = xdMax/15;
		addModulator(dx = new SinLFO(6000,  500, 30000	)).trigger();
		addModulator(dy = new SinLFO(3000,  500, 22472	)).trigger();
		addModulator(dz = new SinLFO(1000,  500, 18420	)).trigger();
		addModulator(x  = new SinLFO(cRad, xdMax - cRad, 0)).trigger();	x.modulateDurationBy(dx);
		addModulator(y  = new SinLFO(cRad, ydMax - cRad, 0)).trigger();	y.modulateDurationBy(dy);
		addModulator(z  = new SinLFO(cRad, zdMax - cRad, 0)).trigger();	z.modulateDurationBy(dz);
	    pSize	= addParam	("Size"			, 0.4	);
	    pChoose = addPick	("Animiation"	, 0	, 3, new String[] {"Pong", "Ball", "Cone"}	);
	}

	void  	StartRun(double deltaMs) 	{ cRad = xdMax*pSize.Val()/6; }
	color	CalcPoint(xyz p) 	  	{
		xyz v = new xyz(x.getValuef(), y.getValuef(), z.getValuef());
		switch(pChoose.Cur()) {
		case 0: return color(0,0,c1c(1 - min(v.distance(p), v.distance(xyzdMax.minus(p)))*.5/cRad));			// balls
		case 1: return color(0,0,c1c(1 - v.distance(p)*.5/cRad));												// ball
		case 2: return color(0,0,c1c(1 - CalcCone(p,v,new xyz(xdMax/2,0,zdMax/2)) * max(.02,.45-pSize.Val())));  // spot
		}
		return color(0,0,0);
	}		
}
//----------------------------------------------------------------------------------------------------------------------------------
public class NDat {
	float xz, yz, zz, hue, sat, speed, angle, den;
	float xoff,yoff,zoff;
	NDat (float _hue, float _sat, float _xz, float _yz, float _zz, float _den, float _speed, float _angle) {
		hue=_hue; sat=_sat; xz=_xz; yz=_yz; zz =_zz; den=_den; speed=_speed; angle=_angle;
		xoff = random(100e3); yoff = random(100e3); zoff = random(100e3);
	}
}

public class Noise extends DPat
{
	int 		CurAnim = -1, numAnims = 6;
	float 		zTime 	= random(10000), zTheta=0;
	float		rtime	= 0, ttime	= 0, transAdd=0;
	int 		XSym=1,YSym=2,RadSym=3;
	int			iSymm;
	ArrayList 	noises 	= new ArrayList();
	_DhP 		pSpeed , pDensity, pRotZ;
	Pick 		pChoose, pSymm;

	Noise(GLucose glucose) {
		super(glucose);
		pRotZ	= addParam("RotZ"	 , .5 );	pSpeed		= addParam("Fast", .55);
		pDensity= addParam("Dens" 	 , .5);
		pSymm 	= addPick("Symmetry" , 0, 4, new String[] {"None", "X", "Y", "Radial"}	);
		pChoose = addPick("Animation", 1, 6, new String[] {"Drip", "Cloud", "Rain", "Fire", "Machine", "Spark"}	);
	}

	void StartRun(double deltaMs) {
		zTime 	+= deltaMs*(pSpeed.Val()-.5)*.002	;
		zTheta	+= deltaMs*(pRotZ .Val()-.5)*.01	;
		rtime	+= deltaMs;
		iSymm	 = pSymm.Cur();
		transAdd = 1*(1 - constrain(rtime - ttime,0,1000)/1000);

		if (pChoose.Cur() != CurAnim) {
			noises.clear(); CurAnim = pChoose.Cur(); ttime = rtime;
			switch(CurAnim) {
			//                          hue sat xz  yz  zz  den mph angle
			case 0: noises.add(new NDat(0  ,0  ,75 ,75 ,150,45 ,3  ,0  )); pSharp.Set(1 ); break; 	// drip
			case 1: noises.add(new NDat(0  ,0  ,100,100,200,45 ,3  ,180)); pSharp.Set(0 ); break;	// clouds
			case 2: noises.add(new NDat(0  ,0  ,2  ,400,2  ,20 ,3  ,0  )); pSharp.Set(.5); break;	// rain
			case 3: noises.add(new NDat(40 ,1  ,100,100,200,10 ,1  ,180)); 
					noises.add(new NDat(0  ,1  ,100,100,200,10 ,5  ,180)); pSharp.Set(0 ); break;	// fire 1
			case 4: noises.add(new NDat(0  ,1  ,40 ,40 ,40 ,15 ,2.5,180));
					noises.add(new NDat(20 ,1  ,40 ,40 ,40 ,15 ,4  ,0  ));
					noises.add(new NDat(40 ,1  ,40 ,40 ,40 ,15 ,2  ,90 ));
					noises.add(new NDat(60 ,1  ,40 ,40 ,40 ,15 ,3  ,-90)); pSharp.Set(.5); break; 	// machine
			case 5: noises.add(new NDat(0  ,1  ,400,100,2  ,15 ,3  ,90 ));
					noises.add(new NDat(20 ,1  ,400,100,2  ,15 ,2.5,0  ));
					noises.add(new NDat(40 ,1  ,100,100,2  ,15 ,2  ,180));
					noises.add(new NDat(60 ,1  ,100,100,2  ,15 ,1.5,270)); pSharp.Set(.5); break; 	// spark
			}
		}

	}

	color CalcPoint(xyz P) {
		color c = 0;
		xyz v 	= P.RotateZ(xyzMid,zTheta);
		if (iSymm == XSym && v.x > xdMax/2) v.x = xdMax-v.x;
		if (iSymm == YSym && v.y > ydMax/2) v.y = ydMax-v.y;

		for (int i=0;i<noises.size(); i++) {
			NDat  n     = (NDat) noises.get(i);
			float zx    = zTime * n.speed * sin(radians(n.angle)),
				  zy    = zTime * n.speed * cos(radians(n.angle));
			
			float b     = (iSymm==RadSym ? noise(zTime*n.speed+n.xoff-Dist(v,xyzMid)/n.xz)
										 : noise(v.x/n.xz+zx+n.xoff,v.y/n.yz+zy+n.yoff,v.z/n.zz+n.zoff))
							*1.8;

			b += 	n.den/100 -.4 + pDensity.Val() -1;
			b +=	transAdd;
			c = 	blendColor(c,color(n.hue,100*n.sat,c1c(b)),ADD);
		}
		return c;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class Play extends DPat
{
	int		nBeats	=  	0;
	_DhP 	pAmp, pRad;
	_DhP 	pRotX, pRotY, pRotZ;
	xyz		Theta 	= new xyz();
	xyz		TSin	= new xyz();
	xyz		TCos	= new xyz();
	
	Pick	pTimePattern, pTempoMult, pShape, pForm;
	int		RandCube;

	Play(GLucose glucose) {
		super(glucose);
		pRotX 		= addParam("RotX", .5);
		pRotY 		= addParam("RotY", .5);
		pRotZ 		= addParam("RotZ", .5);
	    pAmp  		= addParam("Amp" , .2);
	    pRad		= addParam("Rad" 	, .1  		);
		pTempoMult 	= addPick ("TMult"	, 0 , 6		, new String[] {"1x", "2x", "4x", "8x", "16x", "Rand"	}	);
		pTimePattern= addPick ("TPat"	, 0 , 5		, new String[] {"Bounce", "?", "Roll", "Quant", "Accel"	}	);
		pShape	 	= addPick ("Shape"	, 0 , 10	, new String[] {"Line", "Tap", "V", "RandV", "Pyramid",
																	"Wings", "W2", "Sphere", "Cone", "Noise" } 	);
		pForm	 	= addPick ("Form"	, 0 , 3		, new String[] {"Bar", "Volume", "Fade"					}	);
	}

	float 	t,a;
	xyz		cPrev = new xyz(), cCur = new xyz(), cMid = new xyz(), cMidNorm;
	float	LastBeat=3, LastMeasure=3;
	int		CurRandTempo = 1;

	void StartRun(double deltaMs) {
		t = lx.tempo.rampf();
		a = pAmp.Val();

		Theta	.set(pRotX.Val()*PI*2, pRotY.Val()*PI*2, pRotZ.Val()*PI*2);
		TSin	.set(sin(Theta.x), sin(Theta.y), sin(Theta.z));
		TCos	.set(cos(Theta.x), cos(Theta.y), cos(Theta.z));

		if (t<LastMeasure) { CurRandTempo = int(random(4)); } LastMeasure = t;

		switch (pTempoMult.Cur()) {
			case 0: 	t = t;								break;
			case 1: 	t = (t*2. )%1.;						break;
			case 2: 	t = (t*4. )%1.;						break;
			case 3: 	t = (t*8. )%1.;						break;
			case 4: 	t = (t*16.)%1.;						break;
			case 5:		t = (t*pow(2,CurRandTempo))%1.;		break;
		}

		if (t<LastBeat) { cPrev = cCur; cCur = cCur.setRand(); } LastBeat = t;

		switch (pTimePattern.Cur()) {
			case 0: 	t = sin(PI*t);						break;
			case 1: 	t = norm(sin(2*PI*(t+PI/2)),-1,1);	break;
			case 2: 	t = t; 								break;
			case 3: 	t = constrain(int(t*8)/7.,0,1);		break;
			case 4: 	t = t*t*t;							break;
		}

		
		cMid 				= cPrev.interpolate(t,cCur);
		cMidNorm 			= cMid.setNorm();
	}

	color CalcPoint(xyz Px) {
		xyz V 		= 	new xyz();
		xyz P 		= 	Px.setNorm();
						P.RotateXYZ(xyzHalf, Theta, TSin, TCos);

		float mp	= min(P.x, P.z);
		float yt 	= map(t,0,1,.5-a/2,.5+a/2);

		switch (pShape.Cur()) {
			case 0:		V.set(P.x, yt							  , P.z); 							break;	// bouncing line
			case 1:		V.set(P.x, map(cos(PI*t * P.x),-1,1,0,1)  , P.z); 							break;	// top tap
			case 2:		V.set(P.x, a*map(P.x<.5?P.x:1-P.x,0,.5 ,0,t-.5)+.5, P.z);					break;	// V shape
			case 3:		V.set(P.x, P.x < cMidNorm.x ? map(P.x,0,cMidNorm.x, .5,yt) :
													  map(P.x,cMidNorm.x,1, yt,.5), P.z);	  		break;	//  Random V shape

			case 4:		V.set(P.x,	.5*(P.x < cMidNorm.x ? 	map(P.x,0,cMidNorm.x, .5,yt) :
															map(P.x,cMidNorm.x,1, yt,.5)) +
									.5*(P.z < cMidNorm.z ? 	map(P.z,0,cMidNorm.z, .5,yt) :
															map(P.z,cMidNorm.z,1, yt,.5)), P.z); 	break;	//  Random Pyramid shape
															
			case 5:		V.set(P.x, a*map((P.x-.5)*(P.x-.5),0,.25,0,t-.5)+.5, P.z);					break;	// wings
			case 6:		V.set(P.x, a*map((mp -.5)*(mp -.5),0,.25,0,t-.5)+.5, P.z);					break;	// wings

			case 7:		V.set(cMid.x,cMid.y,cMid.z);
						return color(0,0,c1c(1 - (V.distance(Px) > (pRad.getValuef()+.1)*150?1:0)) );		// sphere

			case 8:		V.set(cMid.x,cMid.y,cMid.z);
						return color(0,0,c1c(1 - CalcCone(Px,V,xyzMid) * 0.02 > .5?1:0));  					// cone

			case 9:		return color(100 + noise(P.x,P.y,P.z + (NoiseMove+50000)/1000.)*200,
							85,c1c(P.y < noise(P.x + NoiseMove/2000.,P.z)*(1+a)-a/2.-.1 ? 1 : 0));			//
		}


		switch (pForm.Cur()) {
			case 0:		return color(0,0,c1c(1 - V.distance(P)/pRad.getValuef() > .5?1:0));
			case 1:		return color(0,0,c1c(P.y < V.y ?1:0));
			case 2:		return color(0,0,c1c(1 - V.distance(P)/pRad.getValuef()));

			default:	return color(0,0,c1c(P.y < V.y ?1:0));
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
