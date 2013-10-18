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
				return lx.hsb(0,0,c1c(1 - min(v.distance(p), v.distance(vMir))*.5/cRad));	// balls
		case 1: return lx.hsb(0,0,c1c(1 - v.distance(p)*.5/cRad));							// ball
		case 2: vMir.set(mMax.x/2,0,mMax.z/2);
				return lx.hsb(0,0,c1c(1 - CalcCone(p,v,vMir) * max(.02,.45-pSize.Val())));  	// spot
		}
		return lx.hsb(0,0,0);
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
			return lx.hsb(0,0, 100 * (
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
		pTempoMult 	= addPick ("TMult"	, 5 , 5		, new String[] {"1x", "2x", "4x", "8x", "16x", "Rand"	}	);
		pTimePattern= addPick ("TPat"	, 7 , 7		, new String[] {"Bounce", "Sin", "Roll", "Quant", "Accel", "Deccel", "Slide", "Rand"}	);
		pShape	 	= addPick ("Shape"	, 7 , 15	, new String[] {"Line", "Tap", "V", "RandV",
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
					return lx.hsb(0,max(0,150-d), d); // clock

		case 8:		r = amp*200 * map(bnc,0,1,1,sin(PI*t));
					d = min(
						distToSeg(Px.x, Px.y, a1.getX(r),a1.getY(r), a2.getX(r),a2.getY(r)),
						distToSeg(Px.x, Px.y, a2.getX(r),a2.getY(r), a3.getX(r),a3.getY(r)),
						distToSeg(Px.x, Px.y, a3.getX(r),a3.getY(r), a1.getX(r),a1.getY(r))				// triangle
						);
					d = constrain(30*(rad*40-d),0,100);
					return lx.hsb(0,max(0,150-d), d); // clock

		case 9:		r = amp*200 * map(bnc,0,1,1,sin(PI*t));
					d = min(
						distToSeg(Px.x, Px.y, a1.getX(r),a1.getY(r), a2.getX(r),a2.getY(r)),
						distToSeg(Px.x, Px.y, a2.getX(r),a2.getY(r), a3.getX(r),a3.getY(r)),
						distToSeg(Px.x, Px.y, a3.getX(r),a3.getY(r), a4.getX(r),a4.getY(r)),
						distToSeg(Px.x, Px.y, a4.getX(r),a4.getY(r), a1.getX(r),a1.getY(r))				// quad
					);
					d = constrain(30*(rad*40-d),0,100);
					return lx.hsb(0,max(0,150-d), d); // clock

		case 10:
					r = map(bnc,0,1,a1.r,amp*200*sin(PI*t));
					return lx.hsb(0,0,c1c(.9+2*rad - dist(Px.x,Px.y,a1.getX(r),a1.getY(r))*.03) );		// sphere

		case 11:
					Px.z=mCtr.z; cMid.z=mCtr.z;
					return lx.hsb(0,0,c1c(1 - CalcCone(Px,cMid,mCtr) * 0.02 > .5?1:0));  				// cone

		case 12:	return lx.hsb(100 + noise(Pn.x,Pn.y,Pn.z + (NoiseMove+50000)/1000.)*200,
						85,c1c(Pn.y < noise(Pn.x + NoiseMove/2000.,Pn.z)*(1+amp)-amp/2.-.1 ? 1 : 0));	// noise

		case 13:	float y=0; for (rWave w : waves) y += .5*w.val(Pn.x);
					V.set(Pn.x, .7+y, Pn.z);
					break;

		default:	return lx.hsb(0,0,0);
		}

		return lx.hsb(0,
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

int randDir() { return round(random(1))*2-1; }
//----------------------------------------------------------------------------------------------------------------------------------
boolean dDebug = true;
class dCursor {
	dVertex vCur, vNext, vDest;
	float 	destSpeed;
	int 	posStop, pos,posNext;	// 0 - 65535
	color 	clr;

	dCursor() {}

	boolean isDone	() 									{ return pos==posStop; 										 }
	boolean atDest  ()									{ return vCur.s==vDest.s || 
																 PointDist(vCur.getPoint(0), vDest.getPoint(0)) < 12 || 
																 PointDist(vCur.getPoint(0), vDest.getPoint(15))< 12;}
	void 	setCur 	(dVertex _v, int _p) 				{ p2=null; vCur=_v; pos=_p; PickNext(); 					 }
	void 	setCur	(dPixel  _p) 						{ setCur(_p.v, _p.pos); 									 }
	void	setNext (dVertex _v, int _p, int _s)		{ vNext = _v; posNext = _p<<12; posStop = _s<<12;		 	 }
	void	setDest (dVertex _v, float _speed)			{ vDest = _v; destSpeed = _speed;							 }
	void	onDone	()									{ setCur(vNext, posNext); PickNext(); 						 }

	float  	minDist;
	int 	nTurns;
	boolean bRandEval;

	void 	Evaluate(dVertex v, int p, int s) {
		if (v == null) return; ++nTurns;
		if (bRandEval) {
			if (random(nTurns) < 1) setNext(v,p,s); return; }
		else {
			float d = PointDist(v.getPoint(15), vDest.getPoint(0));
			if (d <  minDist)					{ minDist=d; setNext(v,p,s); }
			if (d == minDist && random(2)<1)  	{ minDist=d; setNext(v,p,s); }
		}
	}

	void 	EvalTurn(dTurn t) { 
		if (t == null || t.pos0<<12 <= pos) return; 
		Evaluate(t.v 	,    t.pos1, t.pos0);
		Evaluate(t.v.opp, 16-t.pos1, t.pos0);
	}

	void 	PickNext() 	{
		bRandEval = random(.05+destSpeed) < .05; minDist=500; nTurns=0;
		Evaluate(vCur.c0, 0, 16);  	Evaluate(vCur.c1, 0, 16);
		EvalTurn(vCur.t0);			EvalTurn(vCur.t1);
	}

	Point 	p1, p2; int i2;

	int draw(int nAmount, SCPattern pat) {
		int nFrom	= (pos    ) >> 12;
		int	nMv 	= min(nAmount, posStop-pos);
		int	nTo 	= min(15,(pos+nMv) >> 12);
		dVertex v 	= vCur;

		if (dDebug) { 	p1 = v.getPoint(nFrom); float d = (p2 == null ? 0 : PointDist(p1,p2)); if (d>5) { println("too wide! quitting: " + d); exit(); }}
								for (int i = nFrom; i <= nTo; i++) { pat.getColors()[v.ci 	  + v.dir*i 	] = clr; }
		if (v.same != null)		for (int i = nFrom; i <= nTo; i++) { pat.getColors()[v.same.ci + v.same.dir*i] = clr; }
		if (dDebug) { 	p2 = v.getPoint(nTo); i2 = nTo; }

		pos += nMv; return nAmount - nMv;
	}	
}

//----------------------------------------------------------------------------------------------------------------------------------
class Worms extends SCPattern {
	float 	StripsPerSec 	= 10;
	float	TrailTime		= 3000;
	int 	numCursors		= 50;
	ArrayList<dCursor> cur  = new ArrayList<dCursor>(30);

	private GraphicEQ eq = null;

	private BasicParameter pBeat	  = new BasicParameter("BEAT",  0);
	private BasicParameter pSpeed     = new BasicParameter("FAST", .2);
	private BasicParameter pBlur      = new BasicParameter("BLUR", .3);
	private BasicParameter pWorms     = new BasicParameter("WRMS", .3);
	private BasicParameter pConfusion = new BasicParameter("CONF", .1);
	private BasicParameter pEQ  	  = new BasicParameter("EQ"  ,  0);
	private BasicParameter pSpawn  	  = new BasicParameter("DIR" ,  0);

	// versions of worms
	// 5. slow worms branching out like a tree

	int 	zMidLat = 82;
	float 	nConfusion;
	private final Click moveChase = new Click(1000);

	xyz 	middle;
	int 	AnimNum() { return floor(pSpawn.getValuef()*(3-.01)); }
	float   randX() { return random(model.xMax-model.xMin)+model.xMin; }
	float   randY() { return random(model.yMax-model.yMin)+model.yMin; }
	xyz 	randEdge() { 
		return random(2) < 1 ? 	new xyz(random(2)<1 ? model.xMin:model.xMax, randY(), zMidLat) 	:
				 				new xyz(randX(), random(2)<1 ? model.yMin:model.yMax, zMidLat)	;
	}

	Worms(GLucose glucose) {
		super(glucose); 
	    addModulator(moveChase).start();
	    addParameter(pBeat);    addParameter(pSpeed);
	    addParameter(pBlur);    addParameter(pWorms);
	    addParameter(pEQ);	    addParameter(pConfusion);
		addParameter(pSpawn);
	    middle = new xyz(model.cx, model.cy, 71);
		if (lattice == null) lattice = new dLattice();
		for (int i=0; i<numCursors; i++) { dCursor c = new dCursor(); reset(c); cur.add(c); }
		onParameterChanged(pEQ); setNewDest();
	}

	public void onParameterChanged(LXParameter parameter) {
		nConfusion = 1-pConfusion.getValuef();
		for (int i=0; i<numCursors; i++) {
			if (parameter==pSpawn) reset(cur.get(i));
			cur.get(i).destSpeed = nConfusion;
		}
	}

	void reset(dCursor c) {
		switch(AnimNum()) {
			case 0:	c.clr = lx.hsb(135,100,100);			// middle to edges
					c.setDest(lattice.getClosest(randEdge()).v, nConfusion);
					c.setCur (lattice.getClosest(middle));
					break;

			case 1:	c.clr = lx.hsb(135,0,100);			// top to bottom
					float xLin = randX();
					c.setDest(lattice.getClosest(new xyz(xLin, 0         , zMidLat)).v, nConfusion);
					c.setCur (lattice.getClosest(new xyz(xLin, model.yMax, zMidLat)));
					break;

			case 2: c.clr = lx.hsb(300,0,100); break; // chase a point around
		}
	}

	void setNewDest() {
		if (AnimNum() != 2) return;
		xyz dest = new xyz(randX(), randY(), zMidLat);
		for (int i=0; i<numCursors; i++) {
			cur.get(i).setDest(lattice.getClosest(dest).v, nConfusion);
			cur.get(i).clr = lx.hsb(0,100,100);	// chase a point around
		}
	}

	void run(double deltaMs) { 
		if (deltaMs > 100) return;
	    if (moveChase.click()) setNewDest();

	    float fBass=0, fTreble=0;
	    if (pEQ.getValuef()>0) {
		    eq.run(deltaMs);
		    fBass 	= eq.getAverageLevel(0, 4);
		    fTreble = eq.getAverageLevel(eq.numBands-7, 7);
		}

		for (int i=0,s=model.points.size(); i<s; i++) {
			color c = colors[i]; float b = brightness(c); 
			if (b>0) colors[i] = color(hue(c), saturation(c), (float)(b-100*deltaMs/(pBlur.getValuef()*TrailTime)));
		}

		int nWorms = floor(pWorms.getValuef() * numCursors * 
					 map(pEQ.getValuef(),0,1,1,constrain(2*fTreble,0,1)));

		for (int i=0; i<nWorms; i++) {
			dCursor c = cur.get(i);
			int nLeft = floor((float)deltaMs*.001*StripsPerSec * 65536 * (5*pSpeed.getValuef()));
			nLeft *= (1 - lx.tempo.rampf()*pBeat.getValuef());
			while(nLeft > 0) { 
				nLeft = c.draw(nLeft,this); if (!c.isDone()) continue;
				c.onDone(); if (c.atDest()) reset(c);
			}
		}
	}


	public void onActive() { if (eq == null) {
		eq = new GraphicEQ(lx, 16);		eq.slope.setValue(0.6);
		eq.level.setValue(0.65);		eq.range.setValue(0.35);
		eq.release.setValue(0.4);
	}}
}
//----------------------------------------------------------------------------------------------------------------------------------
