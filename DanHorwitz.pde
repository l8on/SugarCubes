//----------------------------------------------------------------------------------------------------------------------------------
static 	MidiOutput midiout;
int		nNumRows  = 6, nNumCols = 8;
boolean btwn  (int a,int b,int c)		{ return a >= b && a <= c; 	}

public class _P extends BasicParameter {
	_P(String label, double value) 				{ super(label,value); 									}
	void 	updateValue	(double value) 			{ super.updateValue(value);								}
	float 	Val			() 						{ return getValuef();									}
}

public class Pick {
	Pick	(String label, int _Def, int _Max)	{ Picks=_Max; Default = _Def; tag=label; 									}
	int		Cur() 	 							{ return (CurCol-StartCol)*nNumRows + CurRow; 								}
	int 	Picks, Default, CurRow, CurCol, StartCol, EndCol;
	String	tag;
}
//----------------------------------------------------------------------------------------------------------------------------------
float xMax,yMax,zMax;
public class xyz {	float x,y,z;
			xyz() {x=y=z=0;}
			xyz(Point p					  ) {x=p.fx	; y=p.fy; z=p.fz;}
			xyz(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}
	void	set(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}
	float	distance(xyz b)					{return dist(x,y,z,b.x,b.y,b.z); 	 }
	float	dot     (xyz b)					{return x*b.x + y*b.y + z*b.z; 		 }
	xyz		minus   (xyz b)					{return new xyz(x-b.x,y-b.y,z-b.z);  }
	xyz		plus    (xyz b)					{return new xyz(x+b.x,y+b.y,z+b.z);  }
	xyz		plus	(float b)				{return new xyz(x+b  ,y+b  ,z+b  );  }
	xyz		over	(xyz b)					{return new xyz(x/b.x,y/b.y,z/b.z);  }
	xyz		times	(float b)				{return new xyz(x*b  ,y*b  ,z*b  );  }

	xyz		RotateX	(xyz o, float a) 		{ return new xyz (	x,
																cos(a)*(y-o.y) - sin(a)*(z-o.z) + o.y,
																sin(a)*(y-o.y) + cos(a)*(z-o.z) + o.z);			}
	
	xyz		RotateY	(xyz o, float a) 		{ return new xyz (	cos(a)*(x-o.x) - sin(a)*(z-o.z) + o.x,
																y,
																sin(a)*(x-o.x) + cos(a)*(z-o.z) + o.z);			}
	
	xyz		RotateZ	(xyz o, float a) 		{ return new xyz (	cos(a)*(x-o.x) - sin(a)*(y-o.y) + o.x,
																sin(a)*(x-o.x) + cos(a)*(y-o.y) + o.y,
																z	);											}
	
	
	xyz		setRand	()						{ return new xyz ( random(xMax), random(yMax), random(zMax)); 		}
	xyz		setNorm	() 						{ return new xyz ( x / xMax, y / yMax, z / zMax); 					}
	
	
	float	interp (float a, float b, float c) { return (1-a)*b + a*c; }
	xyz		interpolate(float i, xyz d)		{ return new xyz ( interp(i,x,d.x), interp(i,y,d.y), interp(i,z,d.z)); }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class hsb { float h,s,b;
	hsb(color c) { h=hue(c); s=saturation(c); b=brightness(c); }
	color Out()	 { return color(h%360.,constrain(s,0,100),constrain(b,0,100)); }
}

public class DPat extends SCPattern
{
	float	zSpinHue;
	xyz		xyzMax, xyz0, xyzMid, xyzHalf;

	ArrayList picks	 	= new ArrayList();
	int		nMaxCol  	= 0;
	boolean	bIsActive 	= false;
	float	Dist	 (xyz a, xyz b) 			{ return dist(a.x,a.y,a.z,b.x,b.y,b.z); 			}
	float 	c1c		 (float a) 					{ return 100*constrain(a,0,1); 						}
	int 	mapRow   (int a) 					{ return a == 52 ? 5  : btwn(a,53,57) ? a-53 : a;	}
	int 	unmapRow (int a) 					{ return a == 5  ? 52 : btwn(a,0 , 4) ? a+53 : a;	}
	void 	SetLight (int row, int col, int clr){ if (midiout != null) midiout.sendNoteOn(col, unmapRow(row), clr); }
	void 	keypad   (int row, int col)			{}
	void 	onInactive() 						{ bIsActive=false; }
	void 	onActive  () 						{ bIsActive=true;
		zSpinHue = 0;
		for (int i=0; i<nNumRows	; i++) for (int j=0; j<nNumCols; j++) SetLight(i, j, 0);
		for (int i=0; i<picks.size(); i++) UpdateLights((Pick)picks.get(i));
	}
	void  	StartRun(int deltaMs) 				{}
	color 	CalcPoint(Point p) 	  				{ return color(0,0,0); }
	float 	CalcCone (xyz v1, xyz v2, xyz c) 	{
		return degrees( acos ( v1.minus(c).dot(v2.minus(c)) / (sqrt(v1.minus(c).dot(v1.minus(c))) * sqrt(v2.minus(c).dot(v2.minus(c))) ) ));
	}

	
	void  	run(int deltaMs) {
		StartRun(deltaMs);
		zSpinHue += s_SpinHue ()*deltaMs*.05;
		for (Point p : model.points) {
			hsb cOld = new hsb(colors[p.index]);
			hsb cNew = new hsb (CalcPoint(p));
			if (s_Trails   ()>0) cNew.b  = max(cNew.b,cOld.b - (1-s_Trails()) * deltaMs);
			if (s_Dim      ()>0) cNew.b *= 1-s_Dim	();
			if (s_Saturate ()>0) cNew.s += s_Saturate()*100;
			if (s_SpinHue  ()>0) cNew.h += zSpinHue;
			if (s_ModHue   ()>0) cNew.h += s_ModHue()*360;
			colors[p.index] = cNew.Out();
		}
	}

	void 	controllerChangeReceived(rwmidi.Controller cc) {
		if (cc.getCC() == 7 && btwn(cc.getChannel(),0,7)) Sliders[cc.getChannel()] = 1.*cc.getValue()/127.;
	}

	float	Sliders[] 	= new float[] {0,0,0,0,0,0,0,0};
	float	s_Trails	()	{ return Sliders[0]; }
	float	s_Dim		()	{ return Sliders[1]; }
	float	s_Saturate	()	{ return Sliders[2]; }
	float	s_SpinHue	()	{ return Sliders[3]; }
	float	s_ModHue	()	{ return Sliders[4]; }

	DPat(GLucose glucose) {
		super(glucose);
		xMax 	= model.xMax; yMax = model.yMax; zMax = model.zMax;
		xyzMax 	= new xyz(xMax,yMax,zMax);
		xyzMid	= new xyz(xMax/2, yMax/2, zMax/2);
		xyzHalf	= new xyz(.5,.5,.5);
		xyz0	= new xyz(0,0,0);
	    for (MidiInputDevice  input  : RWMidi.getInputDevices ()) { if (input.toString().contains("APC")) input .createInput (this);}
	    for (MidiOutputDevice output : RWMidi.getOutputDevices()) {
			if (midiout == null && output.toString().contains("APC")) midiout = output.createOutput();
		}
	}

	void UpdateLights(Pick P) {
		if (P==null) return;
		for (int i=0; i<nNumRows; i++) for (int j=P.StartCol; j<=P.EndCol; j++) SetLight(i, j, 0);
		SetLight(P.CurRow, P.CurCol, 3);
	}

	Pick GetPick(int row, int col) {
		for (int i=0; i<picks.size(); i++) { Pick P = (Pick)picks.get(i);
			if (!btwn(col,P.StartCol,P.EndCol)						) continue;
			if (!btwn(row,0,nNumRows-1) 							) continue;
			if (!btwn((col-P.StartCol)*nNumRows + row,0,P.Picks-1)	) continue;
			return P;
		}
		return null;
	}

	void noteOffReceived(Note note) { if (!bIsActive) return;
		int row = mapRow(note.getPitch()), col = note.getChannel();
		UpdateLights(GetPick(row,col));
	}

	void noteOnReceived (Note note) { if (!bIsActive) return;
		int row = mapRow(note.getPitch()), col = note.getChannel();
		Pick P = GetPick(row,col);
		if (P != null) { P.CurRow=row; P.CurCol=col;} else keypad(row, col);
	}

	Pick addPick(String name, int def, int nmax) {
		Pick P 		= new Pick(name, def, nmax); 
		P.StartCol 	= nMaxCol;
		P.EndCol	= P.StartCol + int((nmax-1) / nNumRows);
		nMaxCol 	= P.EndCol	 + 1;
		P.CurRow	= def % nNumRows;
		P.CurCol	= P.StartCol + def/nNumRows;
		picks.add(P);
		return P;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class Pong extends DPat {
	SinLFO x,y,z,dx,dy,dz; 
	float cRad;	_P pSize;
	Pick  pChoose;

	Pong(GLucose glucose) {
		super(glucose);
		cRad = xMax/15;
		addModulator(dx = new SinLFO(6000,  500, 30000	)).trigger();
		addModulator(dy = new SinLFO(3000,  500, 22472	)).trigger();
		addModulator(dz = new SinLFO(1000,  500, 18420	)).trigger();
		addModulator(x  = new SinLFO(cRad, xMax - cRad, 0)).trigger();	x.modulateDurationBy(dx);
		addModulator(y  = new SinLFO(cRad, yMax - cRad, 0)).trigger();	y.modulateDurationBy(dy);
		addModulator(z  = new SinLFO(cRad, zMax - cRad, 0)).trigger();	z.modulateDurationBy(dz);
	    addParameter(pSize 		= new _P("Size", 0.4	));
	    pChoose = addPick("Anim", 0	, 3);
	}

	color Calc(xyz p, xyz v) {
		switch(pChoose.Cur()) {
		case 0: return	color(0,0,c1c(1 - min(v.distance(p), v.distance(xyzMax.minus(p)))*.5/cRad));			// balls
		case 1: return	color(0,0,c1c(1 - v.distance(p)*.5/cRad));												// ball
		case 2: return	color(0,0,c1c(1 - CalcCone(p,v,new xyz(xMax/2,0,zMax/2)) * max(.02,.45-pSize.Val())));  // spot
		}
		return color(0,0,0);
	}

	void  	StartRun(int deltaMs) 	{ cRad = xMax*pSize.Val()/6; }
	color 	CalcPoint(Point p) 	  	{ return Calc(new xyz(p), new xyz(x.getValuef(), y.getValuef(), z.getValuef())); }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class NDat {
	float xz, yz, zz, hue, sat, speed, angle, den, sharp;
	float xoff,yoff,zoff;
	NDat (float _hue, float _sat, float _xz, float _yz, float _zz, float _sharp, float _den, float _speed, float _angle) {
		hue=_hue; sat=_sat; xz=_xz; yz=_yz; zz =_zz; sharp=_sharp; den=_den; speed=_speed; angle=_angle;
		xoff = random(100e3); yoff = random(100e3); zoff = random(100e3);
	}
}

public class Noise extends DPat
{
	int 	CurAnim = -1, numAnims = 6;
	float 	zTime 	= random(10000), zSpin=0;
	float	rtime	= 0, ttime	= 0, transAdd=0;
	int XSym=1,YSym=2,XyzSym=3,RadSym=4;

	ArrayList noises 	= new ArrayList();
	_P 		pSpeed, pSharp, pDensity, pSpin;
	Pick 	pChoose, pSymm;

	Noise(GLucose glucose) {
		super(glucose);
		addParameter(pSpin		= new _P("Spin", .5  ));  addParameter(pSpeed	= new _P("Fast"	, .55));
		addParameter(pSharp		= new _P("Shrp", .5  ));  addParameter(pDensity	= new _P("Dens" , .5 ));
		pSymm 	= addPick("Symm", 0, 5);
		pChoose = addPick("Anim", 0, 6);
	}

	void StartRun(int deltaMs) {
		zTime 	+= deltaMs*(pSpeed.Val()-.5)*.002	;
		zSpin	+= deltaMs*(pSpin .Val()-.5)*.01	;
		rtime	+= deltaMs;
		transAdd = 1*(1 - constrain(rtime - ttime,0,1000)/1000);

		if (pChoose.Cur() != CurAnim) {
			noises.clear(); CurAnim = pChoose.Cur(); ttime = rtime;
			switch(CurAnim) {
			//                          hue sat xz  yz  zz srhp den mph angle
			case 0: noises.add(new NDat(0  ,0  ,75 ,75 ,150,1  ,45 ,3  ,0  )); break; 	// drip
			case 1: noises.add(new NDat(0  ,0  ,100,100,200,0  ,45 ,3  ,180)); break;	// clouds
			case 2: noises.add(new NDat(0  ,0  ,2  ,400,2  ,.5 ,40 ,3  ,0  )); break;	// rain
			case 3: noises.add(new NDat(40 ,100,100,100,200,0  ,30 ,1  ,180)); 
					noises.add(new NDat(0  ,100,100,100,200,0  ,30 ,5  ,180)); break;	// fire 1
			case 4: noises.add(new NDat(0  ,100,40 ,40 ,40 ,.5 ,35 ,2.5,180));
					noises.add(new NDat(20 ,100,40 ,40 ,40 ,.5 ,35 ,4  ,0  ));
					noises.add(new NDat(40 ,100,40 ,40 ,40 ,.5 ,35 ,2  ,90 ));
					noises.add(new NDat(60 ,100,40 ,40 ,40 ,.5 ,35 ,3  ,-90)); break; 	// machine
			case 5: noises.add(new NDat(0  ,100,400,100,2  ,.5 ,35 ,3  ,225));
					noises.add(new NDat(20 ,100,400,100,2  ,.5 ,35 ,2.5,45 ));
					noises.add(new NDat(40 ,400,100,100,2  ,.5 ,35 ,2  ,135));
					noises.add(new NDat(60 ,400,100,100,2  ,.5 ,35 ,1.5,-45)); break; 	// spark
			}
		}
	}

	color CalcPoint(Point p) {
		color c = color(0,0,0);
		int symm = pSymm.Cur();
		for (int i=0;i<noises.size(); i++) {
			xyz v = new xyz(p).RotateZ(xyzMid,zSpin);

			if ((symm == XSym || symm == XyzSym) && v.x > xMax/2) 	v.x = xMax-v.x;
			if ((symm == YSym || symm == XyzSym) && v.y > yMax/2) 	v.y = yMax-v.y;
			if ((			     symm == XyzSym) && v.z > zMax/2) 	v.z = zMax-v.z;

			NDat  n     = (NDat) noises.get(i);
			float deg   = radians(n.angle + (symm==XyzSym?45:0));
			float zx    = zTime * n.speed * sin(deg),
				  zy    = zTime * n.speed * cos(deg),
				  sharp = 1/constrain(2-n.sharp - 2*pSharp.Val(),0,1);

			float b     = (symm==RadSym ? noise(zTime*n.speed+n.xoff-Dist(v,xyzMid)/n.xz)
										: noise(v.x/n.xz+zx+n.xoff,v.y/n.yz+zy+n.yoff,v.z/n.zz+n.zoff))
							*1.8-.4 + n.den/100 + pDensity.Val() -1;

			b += 	 n.den/100 + pDensity.Val() -1;
			b = 	b < .5 ? pow(b,sharp) : 1-pow(1-b,sharp);
			b +=	transAdd;
			c = 	blendColor(c,color(n.hue,n.sat,c1c(b)),ADD);
		}
		return c;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class Play extends DPat
{
	int		nBeats	=  	0;
	_P 		pAmp, pRotX, pRotY, pRotZ, pRad;
	Pick	pTimePattern, pTempoMult, pShape;

	Play(GLucose glucose) {
		super(glucose);
	    addParameter(pAmp  			= new _P("Amp" ,   .2   ));
	    addParameter(pRotX			= new _P("RotX",    0   ));
	    addParameter(pRotY			= new _P("RotY",    0   ));
	    addParameter(pRotZ			= new _P("RotZ",    0   ));
	    addParameter(pRad			= new _P("Rad" ,   .1   ));

		pTimePattern = addPick("TPat",   0 , 5	);
		pTempoMult 	 = addPick("TMul",   5 , 6	);
		pShape	 	 = addPick("Shap",   8 , 10	);

		lx.tempo.setBpm(30);
	}

	float 	t,a;
	xyz		cPrev = new xyz(), cCur = new xyz(), cMid = new xyz(), cMidNorm;
	float	LastBeat=3, LastMeasure=3;
	int		CurRandTempo = 1;
	
	void StartRun(int deltaMs) {
		t = lx.tempo.rampf();
		a = pAmp.Val();
		
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

		cMid 		= cPrev.interpolate(t,cCur);
		cMidNorm 	= cMid.setNorm();
	}

	color CalcPoint(Point p) {
		xyz V 		= new xyz(0,0,0);
		xyz P  		= new xyz(p).setNorm(). RotateX(xyzHalf,pRotX.Val()*PI*2).
											RotateY(xyzHalf,pRotY.Val()*PI*2).
											RotateZ(xyzHalf,pRotZ.Val()*PI*2);
		xyz Px 		= new xyz(p);
		
		float mp   = min(P.x, P.z);
		float yt 	= map(t,0,1,.5-a/2,.5+a/2);
		switch (pShape.Cur()) {
		
			case 0:		V = new xyz(P.x, yt								, P.z); 			break;	// bouncing line
			case 1:		V = new xyz(P.x, map(cos(PI*t * P.x),-1,1,0,1)  , P.z); 			break;	// top tap
			case 2:		V = new xyz(P.x, a*map(P.x<.5?P.x:1-P.x,0,.5 ,0,t-.5)+.5, P.z);		break;	// V shape
			case 3:		V = new xyz(P.x, P.x < cMidNorm.x ? map(P.x,0,cMidNorm.x, .5,yt) :
															map(P.x,cMidNorm.x,1, yt,.5), P.z);	  break;	//  Random V shape

			case 4:		V = new xyz(P.x, .5*(P.x < cMidNorm.x ? map(P.x,0,cMidNorm.x, .5,yt) :
															 map(P.x,cMidNorm.x,1, yt,.5)) +
										 .5*(P.z < cMidNorm.z ? map(P.z,0,cMidNorm.z, .5,yt) :
															 map(P.z,cMidNorm.z,1, yt,.5)), P.z); break;	//  Random Pyramid shape
															
			case 5:		V = new xyz(P.x, a*map((P.x-.5)*(P.x-.5),0,.25,0,t-.5)+.5, P.z);	break;	// wings
			case 6:		V = new xyz(P.x, a*map((mp -.5)*(mp -.5),0,.25,0,t-.5)+.5, P.z);	break;	// wings


			case 7:		V = new xyz(cMid.x,cMid.y,cMid.z);
						return color(0,0,c1c(1 - (V.distance(Px) > (pRad.getValuef()+.1)*100?1:0)) );	// sphere

			case 8:		V = new xyz(cMid.x,cMid.y,cMid.z);
						return color(0,0,c1c(1 - CalcCone(Px,V,xyzMid) * 0.02 > .5?1:0));  			// cone

		}

		return color(0,0,c1c(1 - V.distance(P)/pRad.getValuef() > .5?1:0));
	}
}
//----------------------------------------------------------------------------------------------------------------------------------