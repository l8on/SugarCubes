//----------------------------------------------------------------------------------------------------------------------------------
float 		xdMax,ydMax,zdMax;
int			NumApcRows = 5, NumApcCols = 8;
DGlobals 	DG = new DGlobals();

boolean btwn  (int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
boolean btwn  (double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}

public class Pick {
	int 	NumPicks, Default	,	CurRow	, CurCol	,
			StartRow, EndRow	;
	String  tag		, Desc[]	;
	
	Pick	(String label, int _Def, int _Max, 	int nStart, String d[])	{
		NumPicks 	= _Max; 	Default = _Def; 
		StartRow 	= nStart;	EndRow	= StartRow + int((NumPicks-1) / NumApcCols);
		tag			= label; 	Desc 	= d;
		reset();
	}

	int		Cur() 	 		{ return (CurRow-StartRow)*NumApcCols + CurCol;					}
	String	CurDesc() 		{ return Desc[Cur()]; }
	void	reset() 		{ CurCol = Default % NumApcCols; CurRow	= StartRow + Default / NumApcCols; }

	boolean set(int r, int c)	{
		if (!btwn(r,StartRow,EndRow) || !btwn(c,0,NumApcCols-1) ||
			!btwn((r-StartRow)*NumApcCols + c,0,NumPicks-1)) 	return false;
		CurRow=r; CurCol=c; 									return true;
	}
}

public class DBool {
	boolean def, b;
	String	tag;
	int		row, col;
	void 	reset() { b = def; }
	boolean set	(int r, int c, boolean val) { if (r != row || c != col) return false; b = val; return true; }
	DBool(String _tag, boolean _def, int _row, int _col) {
		def = _def; b = _def; tag = _tag; row = _row; col = _col;
	}
}

public class DParam extends BasicParameter {
	double  dflt;
	DParam	(String label, double value) 		{ super(label,value); dflt=value;		}
	void 	set			(double value) 			{ super.setValue(value);				}
	void 	reset		() 						{ super.setValue(dflt);					}
	float 	Val			() 						{ return getValuef();					}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class xyz {	float x,y,z;
			xyz() {x=y=z=0;}
			xyz(Point p					  ) {x=p.fx	; y=p.fy; z=p.fz;}
			xyz(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}
	void	set(Point p					  ) {x=p.fx	; y=p.fy; z=p.fz;}
	void	set(xyz p					  ) {x=p.x	; y=p.y ; z=p.z ;}
	void	set(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}

	void	zoomX	(float zx) 				{x = x*zx - xdMax*(zx-1)/2;				}
	void	zoomY	(float zy) 				{y = y*zy - ydMax*(zy-1)/2;				}

	float	distance(xyz b)					{return dist(x,y,z,b.x,b.y,b.z); 	 	}
	float	dot     (xyz b)					{return x*b.x + y*b.y + z*b.z; 		 	}
	void	add		(xyz b)					{x += b.x; y += b.y; z += b.z;			}
	void	add		(float b)				{x += b  ; y += b  ; z += b  ;			}
	void	subtract(xyz b)					{x -= b.x; y -= b.y; z -= b.z;			}

	void	RotateZ	  (xyz o, float nSin, float nCos) {
		float nX = nCos*(x-o.x) - nSin*(y-o.y) + o.x;
		float nY = nSin*(x-o.x) + nCos*(y-o.y) + o.y;
		x = nX; y = nY;
	}

	void	RotateX	  (xyz o, float nSin, float nCos) {
		float nY = nCos*(y-o.y) - nSin*(z-o.z) + o.y;
		float nZ = nSin*(y-o.y) + nCos*(z-o.z) + o.z;
		y = nY; z = nZ;
	}

	void	RotateY	  (xyz o, float nSin, float nCos) {
		float nZ = nCos*(z-o.z) - nSin*(x-o.x) + o.z;
		float nX = nSin*(z-o.z) + nCos*(x-o.x) + o.x;
		z = nZ; x = nX;
	}

	void	setRand	()						{ x = random(xdMax); y = random(ydMax); z = random(zdMax); 	}
	void	setNorm	() 						{ x /= xdMax; y /= ydMax; z /= zdMax; 						}
	
	float	interp (float a, float b, float c) { return (1-a)*b + a*c; }

	void	interpolate(float i, xyz d)		{ x = interp(i,x,d.x); y = interp(i,y,d.y); z = interp(i,z,d.z); }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DGlobals {
	boolean		bInit			= false;
	MidiOutput 	APCOut			= null;
	MidiInput	APCIn			= null,		OxygenIn		= null;
	DPat		CurPat			= null;

	float		Sliders[] 		= new float [] {1,0,0,0,0,0,0,0};
	String  	SliderText[]	= new String[] {"Level", "SpinHue", "Spark", "Wiggle", "Trails", "??", "??", "??"};
	
	void 		SetNoteOn	(int row, int col, int clr){ if (APCOut != null) APCOut.sendNoteOn		(col, row, clr); 	}
	void 		SetNoteOff 	(int row, int col, int clr){ if (APCOut != null) APCOut.sendNoteOff		(col, row, clr); 	}
	void 		SetKnob	 	(int cc , int c  , int v  ){ if (APCOut != null) APCOut.sendController	(cc , c, v); 		}

	DBool		GetBool (int i) 					{ return (DBool)CurPat.bools .get(i); }
	Pick 		GetPick (int i) 					{ return (Pick) CurPat.picks .get(i); }
	DParam 		GetParam(int i) 					{ return (DParam) CurPat.params.get(i); }

	float		_Dim		()						{ return Sliders[0]; }
	float		_SpinHue	()						{ return Sliders[1]; }
	float		_Spark		()						{ return Sliders[2]; }
	float		_Wiggle		()						{ return Sliders[3]; }
	float		_Trails		()						{ return Sliders[4]; }

	void		Init		() {
		if (bInit) return; bInit=true;
	    for (MidiOutputDevice o: RWMidi.getOutputDevices()) { if (o.toString().contains("APC")) { APCOut = o.createOutput(); break;}}
		for (MidiInputDevice  i: RWMidi.getInputDevices ()) { if (i.toString().contains("APC")) { i.createInput (this); 	 break;}}
	}
	
	boolean		isFocused  () 		{ return CurPat != null && CurPat == midiEngine.getFocusedDeck().getActivePattern(); }
	void		Deactivate (DPat p) { if (p != CurPat) return; uiDebugText.setText(""); CurPat = null;					 }
	void		Activate   (DPat p) {
		CurPat = p;
		while (lx.tempo.bpm() > 40) lx.tempo.setBpm(lx.tempo.bpm()/2);
		for (int i=0; i<p.params.size(); i++) GetParam(i).reset();
		for (int i=0; i<p.bools .size(); i++) GetBool (i).reset();
		for (int i=0; i<p.picks .size(); i++) GetPick (i).reset();
		UpdateLights();
	}

	void 	SetText() {
		if (!isFocused()) return;
		String Text1="", Text2="";
		for (int i=0; i<CurPat.bools.size(); i++) if (GetBool(i).b) Text1 += " " + GetBool(i).tag       + "   ";
		for (int i=0; i<CurPat.picks.size(); i++) Text1 += GetPick(i).tag + ": " + GetPick(i).CurDesc() + "   ";
		for (int i=0; i<5; i++) 				  Text2 += SliderText[i]  + ": " + int(100*Sliders[i])  + "   ";
		uiDebugText.setText(Text1, Text2);
	}

	void 	UpdateLights() {
		if (!isFocused() || APCOut == null) return;
		for (int i=53;i< 58; i++) for (int j=0; j<NumApcCols; j++) SetNoteOn(i, j, 0);
		for (int i=48;i< 56; i++) SetKnob(0, i, 0);
		for (int i=16;i< 20; i++) SetKnob(0, i, 0);

		for (int i=0; i<CurPat.params.size(); i++) SetKnob		( 0, i<8 ? 48+i : 16 + i - 8, int(GetParam(i).Val()*127) );
		for (int i=0; i<CurPat.picks .size(); i++) SetNoteOn	(GetPick(i).CurRow, GetPick(i).CurCol, 3);
		for (int i=0; i<CurPat.bools .size(); i++) if (GetBool(i).b) 	SetNoteOn	(GetBool(i).row, GetBool(i).col, 1);
													else				SetNoteOff	(GetBool(i).row, GetBool(i).col, 0);
	}

	void 	controllerChangeReceived(rwmidi.Controller cc) {
		if (cc.getCC() == 7 && btwn(cc.getChannel(),0,7)) { Sliders[cc.getChannel()] = 1.*cc.getValue()/127.; }
	}

	void noteOffReceived(Note note) { if (!isFocused()) return;
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<CurPat.bools.size(); i++) if (GetBool(i).set(row, col, false)) return;
		UpdateLights();
	}

	void noteOnReceived (Note note) { if (!isFocused()) return;
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<CurPat.picks.size(); i++) if (GetPick(i).set(row, col)) 	  return;
		for (int i=0; i<CurPat.bools.size(); i++) if (GetBool(i).set(row, col, true)) return;
		println("row: " + row + "  col:   " + col);
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DPat extends SCPattern
{
	ArrayList 	picks	 	= new ArrayList();
	ArrayList 	params 		= new ArrayList();
	ArrayList 	bools		= new ArrayList();
	int			nMaxRow  	= 53;
	float		zSpinHue 	= 0;
	float		LastQuant	= -1, LastJog = -1;
	int 		nPoint	, nPoints;
	xyz			xyzHalf 	= new xyz(.5,.5,.5),
				xyzdMax		= new xyz(),
				xyzMid		= new xyz(),
				xyzJog		= new xyz(0,0,0);
	
	float		NoiseMove	= random(10000);
	DParam		pSharp, pQuantize, pSaturate;
	DBool		pXsym, pYsym, pZsym, pJog;
	float		Dist	 (xyz a, xyz b) 			{ return dist(a.x,a.y,a.z,b.x,b.y,b.z); 	}
	int			c1c		 (float a) 					{ return int(100*constrain(a,0,1));			}
	float 		CalcCone (xyz v1, xyz v2, xyz c) 	{	v1.subtract(c); v2.subtract(c);
														return degrees( acos ( v1.dot(v2) /
															(sqrt(v1.dot(v1)) * sqrt(v2.dot(v2)) ) ));	}
	void  		StartRun(double deltaMs) 			{								}
	color		CalcPoint(xyz p) 					{ return color(0,0,0); 			}
	boolean		IsActive()							{ return this == DG.CurPat;												}
	boolean		IsFocused()							{ return this == midiEngine.getFocusedDeck().getActivePattern();		}
	void 		onInactive() 						{ UpdateState(); }
	void 		onActive  () 						{ UpdateState(); }
	void 		UpdateState() 						{ if (IsFocused() != IsActive()) { if (IsFocused()) DG.Activate(this); else DG.Deactivate(this); } }

	DParam		addParam(String label, double value) {
		DParam P = new DParam(label, value);
		super.addParameter(P);
		params.add(P); return P;
	}

	Pick addPick(String name, int def, int nmax, String[] desc) {
		Pick P 		= new Pick(name, def, nmax, nMaxRow, desc); 
		nMaxRow		= P.EndRow + 1;
		picks.add(P);
		return P;
	}

	DPat(GLucose glucose) {
		super(glucose);
		DG.Init();
		pSharp		=  addParam("Shrp",  0 );
		pQuantize	=  addParam("Qunt",  0 );
		pSaturate	=  addParam("Sat" ,  .5);
		
		nPoints 	=  model.points.size();
		xdMax 		=  model.xMax;
		ydMax 		=  model.yMax;
		zdMax 		=  model.zMax;
		xyzdMax 	=  new xyz(xdMax,ydMax,zdMax);
		xyzMid		=  new xyz(xdMax/2, ydMax/2, zdMax/2);
		
		bools.add(pXsym 	= new DBool("X-SYM", false, 49, 0));
		bools.add(pYsym 	= new DBool("Y-SYM", false, 49, 1));
		bools.add(pZsym 	= new DBool("Z-SYM", false, 49, 2));
		bools.add(pJog		= new DBool("JOGGER",false, 49, 3));
	}

	void run(double deltaMs)
	{
		UpdateState();
		NoiseMove   	+= deltaMs;
		StartRun		(deltaMs);
		zSpinHue 		+= DG._SpinHue ()*deltaMs*.05;
		xyz P 			= new xyz(), tP = new xyz(), pSave = new xyz();
		float fSharp 	= 1/(1.0001-pSharp.Val());
		float fQuant	= pQuantize.Val();
		float fSaturate	= pSaturate.Val();
		
		DG.SetText();
		nPoint 	= 0;
		
		if (fQuant > 0) {
			float tRamp	= (lx.tempo.rampf() % (1./pow(2,int((1-fQuant) * 4))));
			float f = LastQuant; LastQuant = tRamp; if (tRamp > f) return;
		}
	
	
		if (pJog.b) {
			float tRamp	= (lx.tempo.rampf() % .25);
			if (tRamp < LastJog) 
				xyzJog.set(random(xdMax*.2)-.1,
						   random(ydMax*.2)-.1,
						   random(zdMax*.2)-.1);
			LastJog = tRamp; 
		}

		for (Point p : model.points) 	{ nPoint++;
			P.set(p);
			if (pJog.b)	P.add(xyzJog);
			if (DG._Spark () > 0) 	P.y += DG._Spark () * (noise(P.x,P.y+NoiseMove/30  ,P.z)*ydMax - ydMax/2.);
			if (DG._Wiggle() > 0) 	P.y += DG._Wiggle() * (noise(P.x/(xdMax*.3)-NoiseMove/1500.) - .5) * (ydMax/2.);

			color cOld = colors[p.index]; pSave.set(P);
			color cNew = CalcPoint(P);

 			if (pXsym.b)	{ P.set(pSave); tP.set(xdMax-P.x,P.y,P.z); cNew = blendColor(cNew, CalcPoint(tP), ADD); }
			if (pYsym.b) 	{ P.set(pSave); tP.set(P.x,ydMax-P.y,P.z); cNew = blendColor(cNew, CalcPoint(tP), ADD); }
			if (pZsym.b) 	{ P.set(pSave); tP.set(P.x,P.y,zdMax-P.z); cNew = blendColor(cNew, CalcPoint(tP), ADD); }

			float 								b = brightness(cNew)/100.;

 			if (pSharp.Val()>0) 				b = b < .5 ? pow(b,fSharp) : 1-pow(1-b,fSharp);
			if (DG._Trails()>0 && fQuant == 0) 	b = max(b, (float) (brightness(cOld)/100. - (1-DG._Trails()) * deltaMs/200.));

			colors[p.index] = color(
				(hue(cNew) + zSpinHue) % 360,
				saturation(cNew) + 100*(fSaturate*2-1),
				100 *  b * DG._Dim()
			);
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------