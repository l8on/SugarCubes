//----------------------------------------------------------------------------------------------------------------------------------
public class Pong extends DPat {
	SinLFO x,y,z,dx,dy,dz; 
	float cRad;	DParam pSize;
	Pick 	pChoose;
	xyz 	v = new xyz(), vMir =  new xyz();

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
		v.set(x.getValuef(), y.getValuef(), z.getValuef());
		switch(pChoose.Cur()) {
		case 0: vMir.set(xyzdMax); vMir.subtract(p);
				return color(0,0,c1c(1 - min(v.distance(p), v.distance(vMir))*.5/cRad));	// balls
		case 1: return color(0,0,c1c(1 - v.distance(p)*.5/cRad));							// ball
		case 2: vMir.set(xdMax/2,0,zdMax/2);
				return color(0,0,c1c(1 - CalcCone(p,v,vMir) * max(.02,.45-pSize.Val())));  	// spot
		}
		return color(0,0,0);
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class NDat {
	float 	xz, yz, zz, hue, sat, speed, angle, den;
	float	xoff,yoff,zoff;
	float	sinAngle, cosAngle;
	boolean isActive;
	NDat 		  () { isActive=false; }
	boolean	Active() { return isActive; }
	void	set 	(float _hue, float _sat, float _xz, float _yz, float _zz, float _den, float _speed, float _angle) {
		isActive = true;
		hue=_hue; sat=_sat; xz=_xz; yz=_yz; zz =_zz; den=_den; speed=_speed; angle=_angle;
		xoff = random(100e3); yoff = random(100e3); zoff = random(100e3);
	}
}

public class Noise extends DPat
{
	int			CurAnim, iSymm;
	int 		XSym=1,YSym=2,RadSym=3;
	float 		zTime 	= random(10000), zTheta=0, zSin, zCos;
	float		rtime	= 0, ttime	= 0, transAdd=0;
	DParam 		pSpeed , pDensity, pRotZ;
	Pick 		pChoose, pSymm;
	int			_ND = 4;
	NDat		N[] = new NDat[_ND];

	Noise(GLucose glucose) {
		super(glucose);
		pRotZ	= addParam("RotZ"	 , .5 );	pSpeed		= addParam("Fast", .55);
		pDensity= addParam("Dens" 	 , .5);
		pSymm 	= addPick("Symmetry" , 0, 4, new String[] {"None", "X", "Y", "Radial"}	);
		pChoose = addPick("Animation", 1, 6, new String[] {"Drip", "Cloud", "Rain", "Fire", "Machine", "Spark"}	);
		for (int i=0; i<_ND; i++) N[i] = new NDat();
	}

	void StartRun(double deltaMs) {
		zTime 	+= deltaMs*(pSpeed.Val()-.5)*.002	;
		zTheta	+= deltaMs*(pRotZ .Val()-.5)*.01	;
		rtime	+= deltaMs;
		iSymm	 = pSymm.Cur();
		transAdd = 1*(1 - constrain(rtime - ttime,0,1000)/1000);
		zSin	= sin(zTheta);
		zCos	= cos(zTheta);

		if (pChoose.Cur() != CurAnim) {
			CurAnim = pChoose.Cur(); ttime = rtime;
			pRotZ		.reset();	zTheta 		= 0;
			pDensity	.reset();	pSpeed		.reset();	
			for (int i=0; i<_ND; i++) { N[i].isActive = false; }
			
			switch(CurAnim) {
			//                          hue sat xz  yz  zz  den mph angle
			case 0: N[0].set(0  ,0  ,75 ,75 ,150,45 ,3  ,0  ); pSharp.set(1 ); break; 	// drip
			case 1: N[0].set(0  ,0  ,100,100,200,45 ,3  ,180); pSharp.set(0 ); break;	// clouds
			case 2: N[0].set(0  ,0  ,2  ,400,2  ,20 ,3  ,0  ); pSharp.set(.5); break;	// rain
			case 3: N[0].set(40 ,1  ,100,100,200,10 ,1  ,180); 
					N[1].set(0  ,1  ,100,100,200,10 ,5  ,180); pSharp.set(0 ); break;	// fire 1
			case 4: N[0].set(0  ,1  ,40 ,40 ,40 ,15 ,2.5,180);
					N[1].set(20 ,1  ,40 ,40 ,40 ,15 ,4  ,0  );
					N[2].set(40 ,1  ,40 ,40 ,40 ,15 ,2  ,90 );
					N[3].set(60 ,1  ,40 ,40 ,40 ,15 ,3  ,-90); pSharp.set(.5); break; // machine
			case 5: N[0].set(0  ,1  ,400,100,2  ,15 ,3  ,90 );
					N[1].set(20 ,1  ,400,100,2  ,15 ,2.5,0  );
					N[2].set(40 ,1  ,100,100,2  ,15 ,2  ,180);
					N[3].set(60 ,1  ,100,100,2  ,15 ,1.5,270); pSharp.set(.5); break; // spark
			}

			DG.UpdateLights();
		}
		
		for (int i=0; i<_ND; i++) if (N[i].Active()) {
			N[i].sinAngle = sin(radians(N[i].angle));
			N[i].cosAngle = cos(radians(N[i].angle));
		}
	}

	color CalcPoint(xyz P) {
		color c = 0;
		P.RotateZ(xyzMid, zSin, zCos);
		
		if (iSymm == XSym && P.x > xdMax/2) P.x = xdMax-P.x;
		if (iSymm == YSym && P.y > ydMax/2) P.y = ydMax-P.y;

		for (int i=0;i<_ND; i++) if (N[i].Active()) {
			NDat  n     = N[i];
			float zx    = zTime * n.speed * n.sinAngle,
				  zy    = zTime * n.speed * n.cosAngle;
			
			float b     = (iSymm==RadSym ? noise(zTime*n.speed+n.xoff-Dist(P,xyzMid)/n.xz)
										 : noise(P.x/n.xz+zx+n.xoff,P.y/n.yz+zy+n.yoff,P.z/n.zz+n.zoff))
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
	DParam 	pAmp, pRad;
	DParam	pRotX, pRotY, pRotZ;

	float 	t,amp;
	xyz		cPrev 	= new xyz(), cRand	= new xyz(),
			cMid 	= new xyz(), V 		= new xyz(),
			Theta 	= new xyz(), TSin	= new xyz(),
			TCos	= new xyz(), cMidNorm = new xyz(),
			Pn		= new xyz();
	float	LastBeat=3, LastMeasure=3;
	int		CurRandTempo = 1, CurRandTPat = 1;


	Pick	pTimePattern, pTempoMult, pShape, pForm;
	int		RandCube;

	Play(GLucose glucose) {
		super(glucose);
		pRotX 		= addParam("RotX", .5);
		pRotY 		= addParam("RotY", .5);
		pRotZ 		= addParam("RotZ", .5);
	    pAmp  		= addParam("Amp" , .2);
	    pRad		= addParam("Rad" 	, .1  		);
		pTempoMult 	= addPick ("TMult"	, 5 , 6		, new String[] {"1x", "2x", "4x", "8x", "16x", "Rand"	}	);
		pTimePattern= addPick ("TPat"	, 5 , 6		, new String[] {"Bounce", "Sin", "Roll", "Quant", "Accel", "Rand"	}	);
		pShape	 	= addPick ("Shape"	, 4 , 10	, new String[] {"Line", "Tap", "V", "RandV", "Pyramid",
																	"Wings", "W2", "Sphere", "Cone", "Noise" } 	);
		pForm	 	= addPick ("Form"	, 0 , 3		, new String[] {"Bar", "Volume", "Fade"					}	);
	}

	void StartRun(double deltaMs) {
		t 	= lx.tempo.rampf();
		amp = pAmp.Val();

		Theta	.set(pRotX.Val()*PI*2, pRotY.Val()*PI*2, pRotZ.Val()*PI*2);
		TSin	.set(sin(Theta.x), sin(Theta.y), sin(Theta.z));
		TCos	.set(cos(Theta.x), cos(Theta.y), cos(Theta.z));

		if (t<LastMeasure) {
			if (random(2) < 1) CurRandTempo = int(random(4));
			if (random(2) < 1) CurRandTPat  = int(random(5));
		} LastMeasure = t;
			
		int nTempo = pTempoMult	 .Cur(); if (nTempo == 5) nTempo = CurRandTempo;
		int nTPat  = pTimePattern.Cur(); if (nTPat  == 5) nTPat  = CurRandTPat ;

		switch (nTempo) {
			case 0: 	t = t;								break;
			case 1: 	t = (t*2. )%1.;						break;
			case 2: 	t = (t*4. )%1.;						break;
			case 3: 	t = (t*8. )%1.;						break;
			case 4: 	t = (t*16.)%1.;						break;
		}

		if (t<LastBeat) { cPrev.set(cRand); cRand.setRand(); } LastBeat = t;

		switch (nTPat) {
			case 0: 	t = sin(PI*t);						break;
			case 1: 	t = norm(sin(2*PI*(t+PI/2)),-1,1);	break;
			case 2: 	t = t; 								break;
			case 3: 	t = constrain(int(t*8)/7.,0,1);		break;
			case 4: 	t = t*t*t;							break;
		}
		
		cMid.set		(cPrev);	cMid.interpolate	(t,cRand);
		cMidNorm.set	(cMid);		cMidNorm.setNorm();
	}

	color CalcPoint(xyz Px) {
		Px.zoomX(1.3);
		
		Pn.set(Px); Pn.setNorm();
		if (Theta.x != 0)		Pn.RotateX(xyzHalf, TSin.x, TCos.x);
		if (Theta.y != 0)		Pn.RotateY(xyzHalf, TSin.y, TCos.y);
		if (Theta.z != 0)		Pn.RotateZ(xyzHalf, TSin.z, TCos.z);

		float mp	= min(Pn.x, Pn.z);
		float yt 	= map(t,0,1,.5-amp/2,.5+amp/2);

		switch (pShape.Cur()) {
			case 0:	V.set(Pn.x, yt							 	, Pn.z); 							break;	// bouncing line
			case 1:	V.set(Pn.x, map(cos(PI*t * Pn.x),-1,1,0,1)  , Pn.z); 							break;	// top tap
			case 2:	V.set(Pn.x, amp*map(Pn.x<.5?Pn.x:1-Pn.x,0,.5 ,0,t-.5)+.5, Pn.z);				break;	// V shape
			case 3:	V.set(Pn.x, Pn.x < cMidNorm.x ? map(Pn.x,0,cMidNorm.x, .5,yt) :
													map(Pn.x,cMidNorm.x,1, yt,.5), Pn.z);	  		break;	//  Random V shape

			case 4:	V.set(Pn.x,	.5*(Pn.x < cMidNorm.x ? 	map(Pn.x,0,cMidNorm.x, .5,yt) :
															map(Pn.x,cMidNorm.x,1, yt,.5)) +
								.5*(Pn.z < cMidNorm.z ? 	map(Pn.z,0,cMidNorm.z, .5,yt) :
															map(Pn.z,cMidNorm.z,1, yt,.5)), Pn.z); 	break;	//  Random Pyramid shape
														
			case 5:	V.set(Pn.x, amp*map((Pn.x-.5)*(Pn.x-.5),0,.25,0,t-.5)+.5, Pn.z);				break;	// wings
			case 6:	V.set(Pn.x, amp*map((mp -.5)*(mp -.5),0,.25,0,t-.5)+.5, Pn.z);					break;	// wings

			case 7:	V.set(cMid); return color(0,0,c1c(1 - (V.distance(Px) > (pRad.getValuef()+.1)*150?1:0)) );	// sphere
			case 8:	V.set(cMid); return color(0,0,c1c(1 - CalcCone(Px,V,xyzMid) * 0.02 > .5?1:0));  			// cone
			case 9:	
				
				
			case 10:	return color(100 + noise(Pn.x,Pn.y,Pn.z + (NoiseMove+50000)/1000.)*200,
							85,c1c(Pn.y < noise(Pn.x + NoiseMove/2000.,Pn.z)*(1+amp)-amp/2.-.1 ? 1 : 0));			// noise
			default:	return color(0,0,0);
		}


		switch (pForm.Cur()) {
			case 0:		return color(0,0,c1c(1 - V.distance(Pn)/pRad.getValuef() > .5?1:0));
			case 1:		return color(0,0,c1c(Pn.y < V.y ?1:0));
			case 2:		return color(0,0,c1c(1 - V.distance(Pn)/pRad.getValuef()));

			default:	return color(0,0,c1c(Pn.y < V.y ?1:0));
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
