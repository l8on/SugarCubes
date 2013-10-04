//----------------------------------------------------------------------------------------------------------------------------------
public class Pong extends DPat {
	SinLFO x,y,z,dx,dy,dz; 
	float cRad;	DParam pSize;
	Pick 	pChoose;
	xyz 	v = new xyz(), vMir =  new xyz();

	Pong(GLucose glucose) {
		super(glucose);
		cRad = mMax.x/10;
		addModulator(dx = new SinLFO(6000,  500, 30000	)).trigger();
		addModulator(dy = new SinLFO(3000,  500, 22472	)).trigger();
		addModulator(dz = new SinLFO(1000,  500, 18420	)).trigger();
		addModulator(x  = new SinLFO(cRad, mMax.x - cRad, 0)).trigger();	x.modulateDurationBy(dx);
		addModulator(y  = new SinLFO(cRad, mMax.y - cRad, 0)).trigger();	y.modulateDurationBy(dy);
		addModulator(z  = new SinLFO(cRad, mMax.z - cRad, 0)).trigger();	z.modulateDurationBy(dz);
	    pSize	= addParam	("Size"			, 0.4	);
	    pChoose = addPick	("Animiation"	, 0, 2, new String[] {"Pong", "Ball", "Cone"}	);
	}

	void  	StartRun(double deltaMs) 	{ cRad = mMax.x*pSize.Val()/6; }
	color	CalcPoint(xyz p) 	  	{
		v.set(x.getValuef(), y.getValuef(), z.getValuef());
		v.z=0;p.z=0;// ignore z dimension
		switch(pChoose.Cur()) {
		case 0: vMir.set(mMax); vMir.subtract(p);
				return color(0,0,c1c(1 - min(v.distance(p), v.distance(vMir))*.5/cRad));	// balls
		case 1: return color(0,0,c1c(1 - v.distance(p)*.5/cRad));							// ball
		case 2: vMir.set(mMax.x/2,0,mMax.z/2);
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
	float 		zTime , zTheta=0, zSin, zCos, rtime, ttime, transAdd;
	DParam 		pSpeed , pDensity;
	Pick 		pChoose, pSymm;
	int			_ND = 4;
	NDat		N[] = new NDat[_ND];

	Noise(GLucose glucose) {
		super(glucose);
		pSpeed		= addParam("Fast"	, .55);
		pDensity	= addParam("Dens" 	 , .5);
		pSymm 		= addPick("Symmetry" , 0, 3, new String[] {"None", "X", "Y", "Radial"}	);
		pChoose 	= addPick("Animation", 6, 7, new String[] {"Drip", "Cloud", "Rain", "Fire", "Machine", "Spark","VWave", "Wave"}	);
		for (int i=0; i<_ND; i++) N[i] = new NDat();
	}

	void StartPattern() { zTime = random(500); zTheta=0; rtime = 0; ttime = 0; transAdd=0; }
	void StartRun(double deltaMs) {
		zTime 	+= deltaMs*(pSpeed.Val()-.5)*.002	;
		zTheta	+= deltaMs*(pSpin .Val()-.5)*.01	;
		rtime	+= deltaMs;
		iSymm	 = pSymm.Cur();
		transAdd = 1*(1 - constrain(rtime - ttime,0,1000)/1000);
		zSin	= sin(zTheta);
		zCos	= cos(zTheta);

		if (pChoose.Cur() != CurAnim) {
			CurAnim = pChoose.Cur(); ttime = rtime;
			pSpin		.reset();	zTheta 		= 0;
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
		P.RotateZ(mCtr, zSin, zCos);
		
		if (CurAnim == 6 || CurAnim == 7) {
			P.setNorm();
			return color(0,0, 100 * (
							constrain(1-50*(1-pDensity.Val())*abs(P.y-sin(zTime*10  + P.x*(300))*.5 - .5),0,1) + 
			(CurAnim == 7 ? constrain(1-50*(1-pDensity.Val())*abs(P.x-sin(zTime*10  + P.y*(300))*.5 - .5),0,1) : 0))
			);
		}			
			
		if (iSymm == XSym && P.x > mMax.x/2) P.x = mMax.x-P.x;
		if (iSymm == YSym && P.y > mMax.y/2) P.y = mMax.y-P.y;

		for (int i=0;i<_ND; i++) if (N[i].Active()) {
			NDat  n     = N[i];
			float zx    = zTime * n.speed * n.sinAngle,
				  zy    = zTime * n.speed * n.cosAngle;
			
			float b     = (iSymm==RadSym ? noise(zTime*n.speed+n.xoff-Dist(P,mCtr)/n.xz)
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
	public class rAngle {
		float 	prvA, dstA, c;
		float 	prvR, dstR, r;		
		float 	_cos, _sin, x, y;
		float 	fixAngle	(float a, float b) { return a<b ?
										(abs(a-b) > abs(a+2*PI-b) ? a : a+2*PI) :
										(abs(a-b) > abs(a-2*PI-b) ? a : a-2*PI)	; }
		float	getX(float r)	{	return mCtr.x + _cos*r; }
		float	getY(float r)	{	return mCtr.y + _sin*r; }
		void	move() 			{	c 		= interp(t,prvA,dstA); 
									r 		= interp(t,prvR,dstR);
									_cos 	= cos(c); 	_sin 	= sin(c);
	                               x 		= getX(r); 	y 		= getY(r);		}		
		void	set() 			{	prvA 	= dstA; 	dstA 	= random(2*PI); 	prvA = fixAngle(prvA, dstA);
									prvR 	= dstR; 	dstR 	= random(mCtr.y);									}
	}

	int		nBeats	=  	0;
	DParam 	pAmp, pRadius, pBounce;

	float 	t,amp,rad,bnc;
	float	zTheta=0;
	ArrayList<rWave> waves = new ArrayList<rWave>(10);

	rAngle	a1 = new rAngle(), a2 = new rAngle(),
			a3 = new rAngle(), a4 = new rAngle();
	xyz		cPrev 	= new xyz(), cRand	= new xyz(),
			cMid 	= new xyz(), V 		= new xyz(),
			Theta 	= new xyz(), TSin	= new xyz(),
			TCos	= new xyz(), cMidNorm = new xyz(),
			Pn		= new xyz();
	float	LastBeat=3, LastMeasure=3;
	int		CurRandTempo = 1, CurRandTPat = 1;

	Pick	pTimePattern, pTempoMult, pShape;
	int		RandCube;

	Play(GLucose glucose) {
		super(glucose);
	    pRadius		= addParam("Rad" 	, .1  	);
		pBounce		= addParam("Bnc"	, .2	);
	    pAmp  		= addParam("Amp" 	, .2	);
		pTempoMult 	= addPick ("TMult"	, 0 , 5		, new String[] {"1x", "2x", "4x", "8x", "16x", "Rand"	}	);
		pTimePattern= addPick ("TPat"	, 6 , 7		, new String[] {"Bounce", "Sin", "Roll", "Quant", "Accel", "Deccel", "Slide", "Rand"}	);
		pShape	 	= addPick ("Shape"	, 3 , 15	, new String[] {"Line", "Tap", "V", "RandV",
																	"Pyramid", "Wings", "W2", "Clock",
																	"Triangle", "Quad", "Sphere", "Cone",
																	"Noise", "Wave", "?", "?"} 						);
	}

	public class rWave {
		float v0, a0, x0, t,damp,a;
		boolean bDone=false;
		final float len=8;
		rWave(float _x0, float _a0, float _v0, float _damp) { x0=_x0*len; a0=_a0; v0=_v0; t=0; damp = _damp; }
		void move(double deltaMs) {
			t += deltaMs*.001;
			if (t>4) bDone=true;
		}
		float val(float _x) {
			_x*=len;
			float dist = t*v0 - abs(_x-x0);
			if (dist<0) { a=1; return 0; }
			a  = a0*exp(-dist*damp) * exp(-abs(_x-x0)/(.2*len)); // * max(0,1-t/dur)
			return	-a*sin(dist);
		}
	}

	void StartPattern() { zTheta=0; }
	void StartRun(double deltaMs) {
		t 	= lx.tempo.rampf();
		amp = pAmp.Val();
		rad	= pRadius.getValuef();
		bnc	= pBounce.getValuef();		
		zTheta	+= deltaMs*(pSpin .Val()-.5)*.01;

		Theta	.set(pRotX.Val()*PI*2, pRotY.Val()*PI*2, pRotZ.Val()*PI*2 + zTheta);
		TSin	.set(sin(Theta.x), sin(Theta.y), sin(Theta.z));
		TCos	.set(cos(Theta.x), cos(Theta.y), cos(Theta.z));

		if (t<LastMeasure) {
			if (random(3) < 1) { CurRandTempo = int(random(4)); if (CurRandTempo == 3) CurRandTempo = int(random(4));	}
			if (random(3) < 1) { CurRandTPat  = pShape.Cur() > 6 ? 2+int(random(5)) : int(random(7)); 					}
		} LastMeasure = t;
			
		int nTempo = pTempoMult	 .Cur(); if (nTempo == 5) nTempo = CurRandTempo;
		int nTPat  = pTimePattern.Cur(); if (nTPat  == 7) nTPat  = CurRandTPat ;

		switch (nTempo) {
			case 0: 	t = t;								break;
			case 1: 	t = (t*2. )%1.;						break;
			case 2: 	t = (t*4. )%1.;						break;
			case 3: 	t = (t*8. )%1.;						break;
			case 4: 	t = (t*16.)%1.;						break;
		}

		int i=0; while (i< waves.size()) {
			rWave w = waves.get(i);
			w.move(deltaMs); if (w.bDone) waves.remove(i); else i++;
		}

		if ((t<LastBeat && !pKey.b) || DG.KeyPressed>-1) {
			waves.add(new rWave(
						pKey.b ? map(DG.KeyPressed,0,7,0,1) : random(1),		// location
						bnc*10,			// bounciness
						7,				// velocity
						2*(1-amp)));	// dampiness
			DG.KeyPressed=-1;
			if (waves.size() > 5) waves.remove(0);
		}
		
		if (t<LastBeat) {
			cPrev.set(cRand); cRand.setRand();
			a1.set(); a2.set(); a3.set(); a4.set();
		} LastBeat = t;

		switch (nTPat) {
			case 0: 	t = sin(PI*t);							break;	// bounce
			case 1: 	t = norm(sin(2*PI*(t+PI/2)),-1,1);		break;	// sin
			case 2: 	t = t; 									break;	// roll
			case 3: 	t = constrain(int(t*8)/7.,0,1);			break;	// quant
			case 4: 	t = t*t*t;								break;	// accel
			case 5: 	t = sin(PI*t*.5);						break;	// deccel
			case 6: 	t = .5*(1-cos(PI*t));					break;	// slide
		}
		
		cMid.set		(cPrev);	cMid.interpolate	(t,cRand);
		cMidNorm.set	(cMid);		cMidNorm.setNorm();
		a1.move(); a2.move(); a3.move(); a4.move();
	}

	color CalcPoint(xyz Px) {
		if (Theta.x != 0) Px.RotateX(mCtr, TSin.x, TCos.x);
		if (Theta.y != 0) Px.RotateY(mCtr, TSin.y, TCos.y);
		if (Theta.z != 0) Px.RotateZ(mCtr, TSin.z, TCos.z);
		
		Pn.set(Px); Pn.setNorm();

		float mp	= min(Pn.x, Pn.z);
		float yt 	= map(t,0,1,.5-bnc/2,.5+bnc/2);
		float r,d;

		switch (pShape.Cur()) {
		case 0:		V.set(Pn.x, yt							 	, Pn.z); 							break;	// bouncing line
		case 1:		V.set(Pn.x, map(cos(PI*t * Pn.x),-1,1,0,1)  , Pn.z); 							break;	// top tap
		case 2:		V.set(Pn.x, bnc*map(Pn.x<.5?Pn.x:1-Pn.x,0,.5 ,0,t-.5)+.5, Pn.z);				break;	// V shape
		case 3:		V.set(Pn.x, Pn.x < cMidNorm.x ? map(Pn.x,0,cMidNorm.x, .5,yt) :
												map(Pn.x,cMidNorm.x,1, yt,.5), Pn.z);	  			break;	//  Random V shape

		case 4:		V.set(Pn.x,	.5*(Pn.x < cMidNorm.x ? 	map(Pn.x,0,cMidNorm.x, .5,yt) :
														map(Pn.x,cMidNorm.x,1, yt,.5)) +
							.5*(Pn.z < cMidNorm.z ? 	map(Pn.z,0,cMidNorm.z, .5,yt) :
														map(Pn.z,cMidNorm.z,1, yt,.5)), Pn.z); 		break;	//  Random Pyramid shape
													
		case 5:		V.set(Pn.x, bnc*map((Pn.x-.5)*(Pn.x-.5),0,.25,0,t-.5)+.5, Pn.z);				break;	// wings
		case 6:		V.set(Pn.x, bnc*map((mp  -.5)*(mp  -.5),0,.25,0,t-.5)+.5, Pn.z);				break;	// wings

		case 7:		d = min(
						distToSeg(Px.x, Px.y, a1.getX(70),a1.getY(70), mCtr.x, mCtr.y),
						distToSeg(Px.x, Px.y, a2.getX(40),a2.getY(40), mCtr.x, mCtr.y));
					d = constrain(30*(rad*40-d),0,100);
					return color(0,max(0,150-d), d); // clock

		case 8:		r = amp*200 * map(bnc,0,1,1,sin(PI*t));
					d = min(
						distToSeg(Px.x, Px.y, a1.getX(r),a1.getY(r), a2.getX(r),a2.getY(r)),
						distToSeg(Px.x, Px.y, a2.getX(r),a2.getY(r), a3.getX(r),a3.getY(r)),
						distToSeg(Px.x, Px.y, a3.getX(r),a3.getY(r), a1.getX(r),a1.getY(r))				// triangle
						);
					d = constrain(30*(rad*40-d),0,100);
					return color(0,max(0,150-d), d); // clock

		case 9:		r = amp*200 * map(bnc,0,1,1,sin(PI*t));
					d = min(
						distToSeg(Px.x, Px.y, a1.getX(r),a1.getY(r), a2.getX(r),a2.getY(r)),
						distToSeg(Px.x, Px.y, a2.getX(r),a2.getY(r), a3.getX(r),a3.getY(r)),
						distToSeg(Px.x, Px.y, a3.getX(r),a3.getY(r), a4.getX(r),a4.getY(r)),
						distToSeg(Px.x, Px.y, a4.getX(r),a4.getY(r), a1.getX(r),a1.getY(r))				// quad
					);
					d = constrain(30*(rad*40-d),0,100);
					return color(0,max(0,150-d), d); // clock

		case 10:
					r = map(bnc,0,1,a1.r,amp*200*sin(PI*t));
					return color(0,0,c1c(.9+2*rad - dist(Px.x,Px.y,a1.getX(r),a1.getY(r))*.03) );		// sphere

		case 11:
					Px.z=mCtr.z; cMid.z=mCtr.z;
					return color(0,0,c1c(1 - CalcCone(Px,cMid,mCtr) * 0.02 > .5?1:0));  				// cone

		case 12:	return color(100 + noise(Pn.x,Pn.y,Pn.z + (NoiseMove+50000)/1000.)*200,
						85,c1c(Pn.y < noise(Pn.x + NoiseMove/2000.,Pn.z)*(1+amp)-amp/2.-.1 ? 1 : 0));	// noise

		case 13:	float y=0; for (rWave w : waves) y += .5*w.val(Pn.x);
					V.set(Pn.x, .7+y, Pn.z);
					break;

		default:	return color(0,0,0);
		}

		return color(0,
				150-c1c(1 - V.distance(Pn)/rad),
				c1c(1 - V.distance(Pn)/rad));
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
// 0 - TLB, L (b), BLB, B (l)		// Fwd , Down, Back, Up
// 4 - TLF, F (l), BLF, L (f)		// Fwd , Down, Back, Up
// 8 - TRF, R (f), BRF, F (r)		// Back, Down, Fwd , Up
// 12- TRB, B (r), BRB, R (b)		// Back, Down, Fwd , Up
// 1->7, 15->9

class dBolt {
	dStrip v, h;
	int    vpos, hpos;
	dBolt(dStrip _v, dStrip _h, int _vpos, int _hpos) {
		v=_v; h=_h; vpos=_vpos; hpos=_hpos;
		if (v.b0 == null) { v.b0=this; h.b0=this; } 
		else 			  { v.b1=this; h.b1=this; }
	}
}

class dVertex {
	dStrip 	s1	, s2	;
	int 	dir1, dir2	;
	dVertex(dStrip s, int d) {
		int _a = (s.iS%4==1)? (d==1? 5: 3) :
				 (s.iS%4==3)? (d==1? 9:11) :
				 (d==1)  	? (s.Top()?4:12)   : (s.Top()?12:4);
		dir1 = d * (s.isVert() ? -1 : 1);
		dir2 = d;
		s1 	 = DL_.DS[s.iCube() + ((s.iS+_a) % 16)];
		s2 	 = DL_.DS[d == 1 ? 	(s.idx == s.iFace()+3 ? s.idx-3 : s.idx+1):
			   			 		(s.idx == s.iFace()   ? s.idx+3 : s.idx-1)];
		swapout(1 , 6);
		swapout(15,-6);
	}
	void swapout(int a, int b) {
		if (s1.iS == a) { s1 = DL_.DS[s1.idx + b]; dir1 = -dir1; }
		if (s2.iS == a) { s2 = DL_.DS[s2.idx + b]; dir2 = -dir2; }
	}

}

class dStrip  { // THIS WAS SUCH A PAIN!
	int row, col, ci, idx, iS, axis;	// 1-y, 2-left, 3-right
	Strip s; 
	boolean bTop;	// direction: top ccw, bottom cw.

	boolean Top   (){ 	return axis!=1 &&  bTop ;		}
	boolean Bottom(){ 	return axis!=1 && !bTop;		}
	boolean isVert(){ 	return axis==1;					}
	boolean isHorz(){ 	return axis!=1;					}
	int 	iCube (){ 	return 16*floor(idx/16);		}
	int 	iFace (){ 	return iCube() + 4*floor(iS/4);	}

	void 	init(Strip _s, int _i, int _row, int _col)  {
		idx = _i; row = _row; col = _col; s = _s;
		iS 	= idx%16; bTop = (iS%4==0);
		ci  = s.points.get(0).index;
		DL_.DQ[col][row] = iCube();
		switch (iS) {
			case 4:	case 6 : case 12: case 14:	axis=2; break;
			case 0:	case 2 : case 8 : case 10:	axis=3; break;
			default:							axis=1; break;
		}
	}

	void addBolts() {
		v0 = new dVertex(this, 1);
		v1 = new dVertex(this,-1);


		if (iS == 7 && col != 0 && row != 0) 									// left bottom
			new dBolt(this, DL_.GetStrip(row-1,col-1,(col % 2 == 1) ? 8 : 12),  
							4, (col % 2 == 1) ? 6 : 9);	

		if (iS == 7 && col != 0 && row < MaxCubeHeight*2-2) 					// left top
			new dBolt(this, DL_.GetStrip(row+1,col-1,(col % 2 == 1) ? 10 : 14), 
							11, (col % 2 == 1) ? 9 : 6);

		if (iS == 9 && col < NumBackTowers-1 && row < MaxCubeHeight*2-2) 		// right top
			new dBolt(this, DL_.GetStrip(row+1,col+1,(col % 2 == 1) ? 6 : 2), 
							4, (col % 2 == 1) ? 6 : 9);

		if (iS == 9 && col < NumBackTowers-1 && row != 0) 						// right bottom
			new dBolt(this, DL_.GetStrip(row-1,col+1,(col % 2 == 1) ? 4 : 0), 
							11, (col % 2 == 1) ? 9 : 6);
	}

	dBolt 	b0, b1;
	dVertex v0, v1;
}

class dCursor {
	dStrip 	s, sNext;
	int 	nLast,pos,posNext,end;	// 0 - 65535
	int 	dir;			// 1 or -1
	color 	clr;
	
	dCursor(color _c) { clr=_c;}

	boolean isDone() 				 	{ return pos==end; }
	void 	set(dStrip _s, int _dir) 	{ 
			s=_s; dir=_dir; pos = 0; end=65536; nLast=-1; sNext=null;
	}

	boolean	MakeTurn(dBolt b) {
		int nEnd=	(s.isVert() ? b.vpos : b.hpos) <<12;
			nEnd= 	(dir==1 ? nEnd : 65536-nEnd);
		if (nEnd < pos) return false;
		if (s.isVert()) { sNext = b.h; posNext = b.hpos<<12; end = nEnd; }
		else  			{ sNext = b.v; posNext = b.vpos<<12; end = nEnd; }
		return true;
	}

	void 	PickNext() 	{
		if (sNext != null) {
			if (end == 65536) exit();
			end			= 65536;	
			pos			= posNext;
			dir			= randDir(); 
			if (dir<0) pos = end-pos;
			s			= sNext; sNext = null;
			nLast 		= -1;
			return;// could switch again!!
		} else {
			dVertex v = (dir == 1 ? s.v0 : s.v1);
			int r = floor(random(2));
			set(r==0 ? v.s1 : v.s2,r==0 ? v.dir1 : v.dir2);
		}

		// plan to turn the corner
		if (random(6)<1 && s.b0 != null && MakeTurn(s.b0)) return;
		if (random(6)<1 && s.b1 != null && MakeTurn(s.b1)) return;
	}
}

int randDir() { return round(random(1))*2-1; }

class dLattice {
	int   		iTowerStrips=-1;
	dStrip[] 	DS = new dStrip[glucose.model.strips.size()];
	int[][]  	DQ = new int[NumBackTowers][MaxCubeHeight*2];

	int		nStrips() { return iTowerStrips; }
	dStrip GetStrip (int row, int col, int off) { return DS[DQ[col][row]+off]; }
	dLattice() {
		DL_=this;
		int   col = 0, row = -2, i=-1;
		for (Strip strip : glucose.model.strips  ) { i++; 
			if (i % 16 == 0) row+=2;
			if (row >= MaxCubeHeight*2-1) { col++; row = (col%2==1)?1:0; }
			if (col >= NumBackTowers) continue;
			iTowerStrips++	;
			dStrip s = DS[iTowerStrips] = new dStrip();
			s.init(strip, iTowerStrips, row, col);
		}

		for (int j=0; j<iTowerStrips; j++) DS[j].addBolts();
	}
	dStrip 	rand() 				{ return DS[floor(random(iTowerStrips))]; 		}
	void	setRand(dCursor c) 	{ c.set(rand(),randDir());			}
}

dLattice DL_;
//----------------------------------------------------------------------------------------------------------------------------------
class Graph extends SCPattern {

	int draw(dCursor c, int nAmount) {
		int nFrom	= max(c.nLast+1,c.pos >> 12);
		int	nTo 	= min(15,(c.pos+nAmount) >> 12); c.nLast=nTo;
		int	nMv 	= min(nAmount, c.end-c.pos);
			c.pos 	+= nMv;
		for (int i = nFrom; i <= nTo; i++) {
			int n = c.s.ci + (c.dir>0 ? i : 15-i);
			colors[n] = c.clr;
		}
		return nAmount - nMv;
	}

	float 	StripsPerSec 	= 6;
	float	TrailTime		= 1500;
	int 	Cursors 		= 40;
	dCursor	cur[] = new dCursor[Cursors];

	Graph(GLucose glucose) { 
		super(glucose); 
		if (DL_ == null) DL_ = new dLattice();
		for (int i=0; i<Cursors; i++) { cur[i] = new dCursor(color(random(360),50+random(50),50+random(50))); DL_.setRand(cur[i]); }
	}

	void run(double deltaMs) {
			//Test Joints
		if (false) {
			for (int j=0; j<DL_.nStrips(); j++) {
						dStrip s =DL_.DS[j]; dBolt d = s.b0;
						if (d != null) {for (int i=0;i<16;i++) {
							if (s == d.v && i <= d.vpos) colors[d.v.ci+i] 	= color(0,0,30);
							if (s == d.h && i <= d.hpos) colors[d.h.ci+i] 	= color(0,0,30);
						}}

						d = s.b1; 
						if (d != null) {for (int i=0;i<16;i++) {
							if (s == d.v && i >= d.vpos) colors[d.v.ci+i] 	= color(0,0,30);
							if (s == d.h && i >= d.hpos) colors[d.h.ci+i] 	= color(0,0,30);
						}}
			}
		} else {
			for (int i=0; i<Cursors; i++) {
				int nLeft = floor((float)deltaMs*.001*StripsPerSec * 65536);
				while(nLeft > 0) { 	
					nLeft = draw(cur[i], nLeft);
					if (cur[i].isDone()) cur[i].PickNext(); 
				}
			}

			for (int i=0,s=model.points.size(); i<s; i++) {
				float b = brightness(colors[i]); 
				color c = colors[i];
				if (b>0) colors[i] = color(hue(c), saturation(c), 
						(float)(b-100*deltaMs/TrailTime));
			}
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
