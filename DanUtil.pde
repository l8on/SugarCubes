//----------------------------------------------------------------------------------------------------------------------------------
float 		xdMax,ydMax,zdMax;
int			NumApcRows = 5, NumApcCols = 8;
DGlobals 	DG = new DGlobals();

boolean btwn  (int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
boolean btwn  (double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}

public class Pick {
	Pick	(String label, int _Def, int _Max, 	String d[])	{ NumPicks=_Max; Default = _Def; tag=label; Desc = d; }
	int		Cur() 	 							{ return (CurRow-StartRow)*NumApcCols + CurCol; 	}
	int 	NumPicks, Default, CurRow, CurCol, StartRow, EndRow;
	String  Desc[]	;	
	String	tag		;
}
//----------------------------------------------------------------------------------------------------------------------------------
public class _DhP extends BasicParameter {
	double  dflt;
	_DhP	(String label, double value) 		{ super(label,value); dflt=value;		}
	void 	Set			(double value) 			{ super.updateValue(value);				}
	void 	reset		() 						{ super.updateValue(dflt);				}
	float 	Val			() 						{ return getValuef();					}
	boolean ZeroOrOne	()						{ return Val()==0 || Val() == 1;		}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class xyz {	float x,y,z;
			xyz() {x=y=z=0;}
			xyz(Point p					  ) {x=p.fx	; y=p.fy; z=p.fz;}
			xyz(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}
	void	set(Point p					  ) {x=p.fx	; y=p.fy; z=p.fz;}
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
																sin(a)*(y-o.y) + cos(a)*(z-o.z) + o.z);		}
	
	xyz		RotateY	(xyz o, float a) 		{ return new xyz (	cos(a)*(x-o.x) - sin(a)*(z-o.z) + o.x,
																y,
																sin(a)*(x-o.x) + cos(a)*(z-o.z) + o.z);		}
	
	xyz		RotateZ	(xyz o, float a) 		{ return new xyz (	cos(a)*(x-o.x) - sin(a)*(y-o.y) + o.x,
																sin(a)*(x-o.x) + cos(a)*(y-o.y) + o.y,
																z	);										}
	

	void	RotateXYZ (xyz o, xyz t, xyz tsin, xyz tcos) {
					  {	x -= o.x; y -= o.y; z -= o.z; }
 		if (t.x != 0) { y = y*tcos.x - z*tsin.x; z = y*tsin.x + z*tcos.x; }
		if (t.y != 0) { z = z*tcos.y - x*tsin.y; x = z*tsin.y + x*tcos.y; }
		if (t.z != 0) { x = x*tcos.z - y*tsin.z; y = x*tsin.z + y*tcos.z; }
					  { x += o.x; y += o.y; z += o.z; }
	}

	xyz		setRand	()						{ return new xyz ( random(xdMax), random(ydMax), random(zdMax)); 		}
	xyz		setNorm	() 						{ return new xyz ( x / xdMax, y / ydMax, z / zdMax); 					}
	
	float	interp (float a, float b, float c) { return (1-a)*b + a*c; }
	xyz		interpolate(float i, xyz d)		{ return new xyz ( interp(i,x,d.x), interp(i,y,d.y), interp(i,z,d.z)); }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DGlobals {
	boolean		bInit			= false;
	MidiOutput 	APCOut			= null;
	MidiInput	APCIn			= null,		OxygenIn		= null;
	DPat		CurPat			= null,		NextPat			= null;
	boolean 	_XSym			= false,	_YSym			= false,
				_ZSym			= false,	_RSym			= false;
	String		Text1 			= "",		Text2 			= "";

	float		Sliders[] 		= new float[] {0,0,0,0,0,0,0,0};
	String  	SliderText[]	= new String[] {"Trails", "Dim", "Saturate", "SpinHue", "Hue", "NoiseHue", "Spark", "Wiggle"};

	int 	mapRow   (int a) 					{ return btwn(a,53,57) ? a-53 : a;			}
	int 	unmapRow (int a) 					{ return btwn(a,0 , 4) ? a+53 : a;			}

	void 	SetLight (int row, int col, int clr){ if (APCOut != null) APCOut.sendNoteOn(col, unmapRow(row), clr); }
	void 	SetKnob	 (int cc , int chan,int val){ if (APCOut != null) APCOut.sendController(cc , chan		  , val); }

	float	_Trails		()						{ return Sliders[0]; }
	float	_Dim		()						{ return Sliders[1]; }
	float	_Saturate	()						{ return Sliders[2]; }
	float	_SpinHue	()						{ return Sliders[3]; }
	float	_ModHue		()						{ return Sliders[4]; }
	float	_NoiseHue	()						{ return Sliders[5]; }
	float	_Spark		()						{ return Sliders[6]; }
	float	_Wiggle		()						{ return Sliders[7]; }

	void	Init		() {
		if (bInit) return; bInit=true;
	    for (MidiOutputDevice output : RWMidi.getOutputDevices()) {
			if (APCOut == null && output.toString().contains("APC")) APCOut = output.createOutput();
		}

		for (MidiInputDevice  input  : RWMidi.getInputDevices ()) {
			if (input.toString().contains("APC")) input.createInput (this);
		}
	}	

	void SetText()
	{
		Text1 = ""; Text2 = "";
		Text1  += " XSym:  " + (_XSym ? "ON" : "OFF") + "    ";
		Text1  += " YSym:  " + (_YSym ? "ON" : "OFF") + "    ";
		Text1  += " ZSym:  " + (_ZSym ? "ON" : "OFF") + "    ";
		Text1  += " RSym:  " + (_RSym ? "ON" : "OFF") + "    ";
		for (int i=0; i<CurPat.picks.size(); i++) {
			Pick P = (Pick)CurPat.picks.get(i); Text1 += P.tag + ": " + P.Desc[P.Cur()] + "    ";
		}

		Text2  = "SLIDERS: ";
		for (int i=0; i<8; i++) if (SliderText[i] != "") {
			Text2 += SliderText[i] + ": " + int(100*Sliders[i]) + "     "; }

		uiDebugText.setText(Text1, Text2);
	}

	void 	controllerChangeReceived(rwmidi.Controller cc) {
		if (cc.getCC() == 7 && btwn(cc.getChannel(),0,7)) { Sliders[cc.getChannel()] = 1.*cc.getValue()/127.; }

		else if (cc.getCC() == 15 && cc.getChannel() == 0) {
			lx.engine.getDeck(1).getCrossfader().setValue( 1.*cc.getValue()/127.);
		}

		//else { println(cc.getCC() + " " + cc.getChannel() + " " + cc.getValue()); }
	}
	
	void	Deactivate (DPat p) { if (p == CurPat) { uiDebugText.setText(""); CurPat = NextPat; } NextPat = null; }
	void	Activate   (DPat p) {
		NextPat = CurPat; CurPat = p;
		while (lx.tempo.bpm() > 40) lx.tempo.setBpm(lx.tempo.bpm()/2);
		for (int i=0; i<p.paramlist.size(); i++) ((_DhP)p.paramlist.get(i)).reset();
		UpdateLights();
	}

	void 	UpdateLights() {
		for (int i=0; i<NumApcRows	; i++) for (int j=0; j<NumApcCols; j++) SetLight(i, j, 0);
		for (int i=48;i< 56		; i++) SetKnob(0, i, 0);
		for (int i=16;i< 20		; i++) SetKnob(0, i, 0);
		for (int i=0; i<CurPat.picks.size()	; i++) {
			Pick P = (Pick)CurPat.picks.get(i); SetLight(P.CurRow, P.CurCol, 3);
		}
		SetLight(82, 0, _XSym ? 3 : 0);
		SetLight(83, 0, _YSym ? 3 : 0);
		SetLight(84, 0, _ZSym ? 3 : 0);
		SetLight(85, 0, _RSym ? 3 : 0);
		
		for (int i=0; i<CurPat.paramlist.size(); i++) {
			_DhP Param = (_DhP)CurPat.paramlist.get(i);
			SetKnob	( 0, i<=55 ? 48+i : 16 + i - 8, int(Param.Val()*127) );
		}
	}
	
	double Tap1 = 0;
	double getNow() { return millis() + 1000*second() + 60*1000*minute() + 3600*1000*hour(); }

	void noteOffReceived(Note note) {
		if (CurPat == null) return;
		int row = DG.mapRow(note.getPitch()), col = note.getChannel();

		if (row == 50 && col == 0 && btwn(getNow() - Tap1,5000,300*1000)) {	// hackish tapping mechanism
			double bpm = 32.*60000./(getNow()-Tap1);
			while (bpm < 20) bpm*=2;
			while (bpm > 40) bpm/=2;
			lx.tempo.setBpm(bpm); lx.tempo.trigger(); Tap1=0; println("Tap Set - " + bpm + " bpm");
		}

		UpdateLights();
	}

	void noteOnReceived (Note note) {
		if (CurPat == null) return;
		int row = mapRow(note.getPitch()), col = note.getChannel();
		
			 if (row == 50 && col == 0) 	{ lx.tempo.trigger(); Tap1 = getNow(); 	}
		else if (row == 82 && col == 0) 	_XSym = !_XSym	;
		else if (row == 83 && col == 0) 	_YSym = !_YSym	;
		else if (row == 84 && col == 0) 	_ZSym = !_ZSym	;
		else if (row == 85 && col == 0) 	_RSym = !_RSym	;
		else {
			for (int i=0; i<CurPat.picks.size(); i++) { Pick P = (Pick)CurPat.picks.get(i);
				if (!btwn(row,P.StartRow,P.EndRow)							) continue;
				if (!btwn(col,0,NumApcCols-1) 								) continue;
				if (!btwn((row-P.StartRow)*NumApcCols + col,0,P.NumPicks-1)	) continue;
				P.CurRow=row; P.CurCol=col; return;
			}
			//println(row + " " + col); 
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DPat extends SCPattern
{
	ArrayList 	picks	 	= new ArrayList();
	ArrayList 	paramlist 	= new ArrayList();
	int			nMaxRow  	= 0;
	float		zSpinHue 	= 0;
	int 		nPoint	, nPoints;
	xyz			xyzHalf 	= new xyz(.5,.5,.5),
				xyzdMax		= new xyz(),
				xyzMid		= new xyz();
	
	float		NoiseMove	= random(10000);
	_DhP		pSharp, pRotX, pRotY, pRotZ;
	float		Dist	 (xyz a, xyz b) 			{ return dist(a.x,a.y,a.z,b.x,b.y,b.z); 	}
	int			c1c		 (float a) 					{ return int(100*constrain(a,0,1));			}
	float 		CalcCone (xyz v1, xyz v2, xyz c) 	{ return degrees( acos ( v1.minus(c).dot(v2.minus(c)) /
															(sqrt(v1.minus(c).dot(v1.minus(c))) * sqrt(v2.minus(c).dot(v2.minus(c))) ) ));	}
	void  		StartRun(double deltaMs) 			{								}
	color		CalcPoint(xyz p) 					{ return color(0,0,0); 			}
	boolean		IsActive()							{ return this == DG.CurPat;		}
	void 		onInactive() 						{ DG.Deactivate(this); 	}
	void 		onActive  () 						{ DG.Activate(this); 	}

	_DhP addParam(String label, double value) {
		_DhP P = new _DhP(label, value);		
		super.addParameter(P);
		paramlist.add(P); return P;
	}
		
	Pick addPick(String name, int def, int nmax, String[] desc) {
		Pick P 		= new Pick(name, def, nmax, desc); 
		P.StartRow	= nMaxRow;
		P.EndRow	= P.StartRow + int((nmax-1) / NumApcCols);
		nMaxRow		= P.EndRow + 1;
		P.CurCol	= def % NumApcCols;
		P.CurRow	= P.StartRow + def / NumApcCols;
		picks.add(P);
		return P;
	}

	DPat(GLucose glucose) {
		super(glucose);
		DG.Init();
		pSharp		=  addParam("Shrp"	,  0);
		nPoints 	=  model.points.size();
		xdMax 		=  model.xMax;
		ydMax 		=  model.yMax;
		zdMax 		=  model.zMax;
		xyzdMax 	=  new xyz(xdMax,ydMax,zdMax);
		xyzMid		=  new xyz(xdMax/2, ydMax/2, zdMax/2);
	}

	void run(double deltaMs)
	{
		NoiseMove   	+= deltaMs;
		StartRun		(deltaMs);
		zSpinHue 		+= DG._SpinHue ()*deltaMs*.05;
		xyz P 			= new xyz();
		float modhue  	= DG._ModHue  ()==0 ? 0 : DG._ModHue  ()*360;
		float fSharp 	= 1/(1.01-pSharp.Val());

		DG.SetText();
		nPoint 	= 0;
		for (Point p : model.points) 	{ nPoint++;
			if (!IsActive()) { colors[p.index] = color(0,0,0); continue; }

			P.set(p);

			if (DG._Spark () > 0) P.y += DG._Spark () * (noise(P.x,P.y+NoiseMove/30  ,P.z)*ydMax - ydMax/2.);
			if (DG._Wiggle() > 0) P.y += DG._Wiggle() * (noise(P.x/(xdMax*.3)-NoiseMove/1500.) - .5) * (ydMax/2.);

			color cOld 	= colors[p.index];

			color 			cNew = CalcPoint(P);
			if (DG._XSym)	cNew = blendColor(cNew, CalcPoint(new xyz(xdMax-P.x,P.y,P.z)), ADD);
			if (DG._YSym) 	cNew = blendColor(cNew, CalcPoint(new xyz(P.x,ydMax-P.y,P.z)), ADD);
			if (DG._ZSym) 	cNew = blendColor(cNew, CalcPoint(new xyz(P.x,P.y,zdMax-P.z)), ADD);

			float b = brightness(cNew)/100.;
			b = b < .5 ? pow(b,fSharp) : 1-pow(1-b,fSharp);

			float noizhue = DG._NoiseHue()==0 ? 0 : DG._NoiseHue()*360*noise(
													P.x/(xdMax*.3)+NoiseMove*.0003,
													P.y/(ydMax*.3)+NoiseMove*.00025,
													P.z/(zdMax*.3)+NoiseMove*.0002	);

			cNew = color( (hue(cNew) + modhue + zSpinHue - noizhue) % 360,
						saturation(cNew) + 100*DG._Saturate(),
						100 *  (DG._Trails()==0 ? b : max(b, (float) (brightness(cOld)/100. - (1-DG._Trails()) * deltaMs/200.)))
							*  (DG._Dim   ()==0 ? 1 : 1-DG._Dim())
						);
						   
			colors[p.index] = cNew;
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
