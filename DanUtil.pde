//----------------------------------------------------------------------------------------------------------------------------------
static 	MidiOutput midiout;
int		nNumRows  = 5, nNumCols = 8;
float xdMax,ydMax,zdMax;
String	DanTextLine1 = "", DanTextLine2 = "";

boolean btwn  (int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
boolean btwn  (double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}

public class Pick {
	Pick	(String label, int _Def, int _Max)	{ NumPicks=_Max; Default = _Def; tag=label; 								}
	int		Cur() 	 							{ return (CurRow-StartRow)*nNumCols + CurCol; 								}
	int 	NumPicks, Default, CurRow, CurCol, StartRow, EndRow;
	String	tag;
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

public class IndexNums {
	int 	point	;//, cube	, tower	 , face	 , strip	;
	int 	nPoints	;//, nCubes, nTowers, nFaces, nStrips	;
//	boolean isHoriz;
	void reset() { point=0;}//cube=tower=face=strip=0; }
}
IndexNums iCur = new IndexNums();
//----------------------------------------------------------------------------------------------------------------------------------
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
	
	xyz		setRand	()						{ return new xyz ( random(xdMax), random(ydMax), random(zdMax)); 		}
	xyz		setNorm	() 						{ return new xyz ( x / xdMax, y / ydMax, z / zdMax); 					}
	
	float	interp (float a, float b, float c) { return (1-a)*b + a*c; }
	xyz		interpolate(float i, xyz d)		{ return new xyz ( interp(i,x,d.x), interp(i,y,d.y), interp(i,z,d.z)); }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DPat extends SCPattern
{
	float		zSpinHue;
	xyz			xyzdMax, xyz0, xyzMid, xyzHalf;
	PFont 		itemFont 	= createFont("Lucida Grande", 11);
	ArrayList 	picklist 	= new ArrayList();
	ArrayList 	paramlist 	= new ArrayList();
	int			nMaxRow  	= 0;
	boolean		bIsActive 	= false;
	float		NoiseMove	= random(10000);

	float		Dist	 (xyz a, xyz b) 			{ return dist(a.x,a.y,a.z,b.x,b.y,b.z); 	}
	int			c1c		 (float a) 					{ return int(100*constrain(a,0,1));			}
	int 		mapRow   (int a) 					{ return btwn(a,53,57) ? a-53 : a;			}
	int 		unmapRow (int a) 					{ return btwn(a,0 , 4) ? a+53 : a;			}
	void 		SetLight (int row, int col, int clr){ if (midiout != null) midiout.sendNoteOn(col, unmapRow(row), clr); }
	void 		keypad   (int row, int col)			{ println(row + " " + col); }
	void 		onInactive() 						{ bIsActive=false; DanTextLine1 = ""; DanTextLine2 = "";}
	void 		onActive  () 						{ bIsActive=true;
		zSpinHue = 0;
		for (int i=0; i<paramlist.size(); i++) ((_DhP)paramlist.get(i)).reset();
		while (lx.tempo.bpm() > 40) lx.tempo.setBpm(lx.tempo.bpm()/2);
		UpdateLights();
	}
	void  	StartRun(int deltaMs) 				{	}
	color	CalcPoint(xyz p) 					{ return color(0,0,0); }
	float 	CalcCone (xyz v1, xyz v2, xyz c) 	{
		return degrees( acos ( v1.minus(c).dot(v2.minus(c)) / (sqrt(v1.minus(c).dot(v1.minus(c))) * sqrt(v2.minus(c).dot(v2.minus(c))) ) ));
	}

	void AddDanText() {
		DanTextLine1  = "APC40:   ";
		for (int i=0; i<picklist.size()	; i++) { Pick P = (Pick)picklist.get(i); DanTextLine1 += P.tag + ": " + P.Cur() + "    "; }
		DanTextLine1  += " X-Symm:   " + (_XSym   ? "ON" : "OFF") + "    ";
		DanTextLine1  += " Y-Symm:   " + (_YSym   ? "ON" : "OFF") + "    ";
		DanTextLine1  += " Z-Symm:   " + (_ZSym   ? "ON" : "OFF") + "    ";
		DanTextLine1  += " Rad-Sym:  " + (_RadSym ? "ON" : "OFF") + "    ";
//		DanTextLine1  += " Horiz:    " + (_Horiz  ? "ON" : "OFF") + "    ";
//		DanTextLine1  += " Vert:     " + (_Vert   ? "ON" : "OFF") + "    ";

		DanTextLine2  = "SLIDERS: ";
		for (int i=0; i<8; i++) if (SliderText[i] != "") { DanTextLine2 += SliderText[i] + ": " + Sliders[i] + "     "; }
	}

	void  	run(int deltaMs) {
		NoiseMove   += deltaMs;
		xdMax 		=  model.xMax;
		ydMax 		=  model.yMax;
		zdMax 		=  model.zMax;
		xyzdMax 	=  new xyz(xdMax,ydMax,zdMax);
		xyzMid		=  new xyz(xdMax/2, ydMax/2, zdMax/2);
		StartRun		(deltaMs);
		zSpinHue 	+= s_SpinHue ()*deltaMs*.05;
		float fSharp = 1/(1.01-pSharp.Val());
		AddDanText();
		iCur.reset();							iCur.nPoints = model.points.size();
//		iCur.nTowers = model.towers.size();		iCur.nCubes  = model.cubes .size();
//		iCur.nFaces  = model.faces .size();		iCur.nStrips = model.strips.size();

//		for (Tower t : model.towers) 	{	iCur.tower++;
//		for (Cube  c : t.cubes) 		{	iCur.cube ++; 
//		for (Face  f : c.faces) 		{	iCur.face ++; 
//		for (Strip s : f.strips) 		{	iCur.strip++; iCur.isHoriz= (iCur.strip % 2 == 1 || iCur.strip < 5) ? true : false;
		for (Point p : model.points) 	{	iCur.point++; 
			xyz P 		= new xyz(p);

			if (s_Spark () > 0) P.y += s_Spark () * (noise(P.x,P.y+NoiseMove/30  ,P.z)*ydMax - ydMax/2.);
			if (s_Wiggle() > 0) P.y += s_Wiggle() * (noise(P.x/(xdMax*.3)-NoiseMove/1500.) - .5) * (ydMax/2.);

			color cOld 	= colors[p.index];
			color cNew 	= CalcPoint(P);

//			if (_Horiz  && !iCur.isHoriz) { colors[p.index] = 0; continue; }
//			if (_Vert   &&  iCur.isHoriz) { colors[p.index] = 0; continue; }		
			if (_XSym)	cNew = blendColor(cNew, CalcPoint(new xyz(xdMax-P.x,P.y,P.z)), ADD);
			if (_YSym) 	cNew = blendColor(cNew, CalcPoint(new xyz(P.x,ydMax-P.y,P.z)), ADD);
			if (_ZSym) 	cNew = blendColor(cNew, CalcPoint(new xyz(P.x,P.y,zdMax-P.z)), ADD);

			float b = brightness(cNew)/100.;
			b = b < .5 ? pow(b,fSharp) : 1-pow(1-b,fSharp);

			float modhue  = s_ModHue  ()>0 ? s_ModHue  ()*360:0;

			float noizhue = s_NoiseHue()>0 ? s_NoiseHue()*360*noise(	P.x/(xdMax*.3)+NoiseMove/3000.,
															P.y/(ydMax*.3)+NoiseMove/4000.,
															P.z/(zdMax*.3)+NoiseMove/5000.) : 0;

			cNew = color( (hue(cNew) + modhue + zSpinHue - noizhue) % 360,
						saturation(cNew) + 100*s_Saturate(),
						100 *  (s_Trails()==0 ? b : max(b, brightness(cOld)/100. - (1-s_Trails()) * deltaMs/200.))
							*  (s_Dim   ()==0 ? 1 : 1-s_Dim())
						);
						   
			colors[p.index] = cNew;
		}
//		}}}}
	}

	void 	controllerChangeReceived(rwmidi.Controller cc) {
		if (cc.getCC() == 7 && btwn(cc.getChannel(),0,7)) Sliders[cc.getChannel()] = 1.*cc.getValue()/127.;
	}

	public float	Sliders[] 	= new float[] {0,0,0,0,0,0,0,0};
	String  SliderText[]= new String[] {"Trails", "Dim", "Saturate", "SpinHue", "Hue", "NoiseHue", "Spark", "Wiggle"};
	float	s_Trails	()	{ return Sliders[0]; }
	float	s_Dim		()	{ return Sliders[1]; }
	float	s_Saturate	()	{ return Sliders[2]; }
	float	s_SpinHue	()	{ return Sliders[3]; }
	float	s_ModHue	()	{ return Sliders[4]; }
	float	s_NoiseHue	()	{ return Sliders[5]; }
	float	s_Spark		()	{ return Sliders[6]; }
	float	s_Wiggle	()	{ return Sliders[7]; }
	_DhP	pSharp;

	DPat(GLucose glucose) {
		super(glucose);
		xyzHalf	= new xyz(.5,.5,.5);
		xyz0	= new xyz(0,0,0);
		pSharp	= addParam("Shrp", 0);
		
	    for (MidiInputDevice  input  : RWMidi.getInputDevices ()) { if (input.toString().contains("APC")) input .createInput (this);}
	    for (MidiOutputDevice output : RWMidi.getOutputDevices()) {
			if (midiout == null && output.toString().contains("APC")) midiout = output.createOutput();
		}
	}

	void UpdateLights() {
		for (int i=0; i<nNumRows		; i++) for (int j=0; j<nNumCols; j++) SetLight(i, j, 0);
		for (int i=0; i<picklist.size()	; i++) {
			Pick P = (Pick)picklist.get(i); SetLight(P.CurRow, P.CurCol, 3);
		}
		SetLight(82, 0, _XSym 	? 3 : 0);
		SetLight(83, 0, _YSym 	? 3 : 0);
		SetLight(84, 0, _ZSym 	? 3 : 0);
		SetLight(85, 0, _RadSym ? 3 : 0);
//		SetLight(86, 0, _Horiz  ? 3 : 0);
//		SetLight(87, 0, _Vert   ? 3 : 0);
	}

	Pick GetPick(int row, int col) {
		for (int i=0; i<picklist.size(); i++) { Pick P = (Pick)picklist.get(i);
			if (!btwn(row,P.StartRow,P.EndRow)							) continue;
			if (!btwn(col,0,nNumCols-1) 								) continue;
			if (!btwn((row-P.StartRow)*nNumCols + col,0,P.NumPicks-1)	) continue;
			return P;
		}
		return null;
	}
	
	double Tap1 = 0;
	double getNow() { return millis() + 1000*second() + 60*1000*minute() + 3600*1000*hour(); }
	
	void noteOffReceived(Note note) { if (!bIsActive) return;
		int row = mapRow(note.getPitch()), col = note.getChannel();

		if (row == 50 && col == 0 && btwn(getNow() - Tap1,5000,300*1000)) {	// hackish tapping mechanism
			double bpm = 32.*60000./(getNow()-Tap1);
			while (bpm < 20) bpm*=2;
			while (bpm > 40) bpm/=2;
			lx.tempo.setBpm(bpm); lx.tempo.trigger(); Tap1=0; println("Tap Set - " + bpm + " bpm");
		}

		UpdateLights();
	}

	boolean _XSym=false, _YSym=false, _ZSym=false, _RadSym=false; //, _Horiz=false, _Vert=false;
	
	void noteOnReceived (Note note) { if (!bIsActive) return;
		int row = mapRow(note.getPitch()), col = note.getChannel();
		Pick P = GetPick(row,col);
			 if (P != null) 				{ P.CurRow=row; P.CurCol=col; 			}
		else if (row == 50 && col == 0) 	{ lx.tempo.trigger(); Tap1 = getNow(); 	}
		else if (row == 82 && col == 0) 	_XSym 	= !_XSym	;
		else if (row == 83 && col == 0) 	_YSym 	= !_YSym	;
		else if (row == 84 && col == 0) 	_ZSym 	= !_ZSym	;
		else if (row == 85 && col == 0) 	_RadSym = !_RadSym	;
		else 								keypad(row, col)	;
	}

	_DhP addParam(String label, double value) {
		_DhP P = new _DhP(label, value);		
		super.addParameter(P);
		paramlist.add(P); return P;
	}
		
	Pick addPick(String name, int def, int nmax) {
		Pick P 		= new Pick(name, def, nmax); 
		P.StartRow	= nMaxRow;
		P.EndRow	= P.StartRow + int((nmax-1) / nNumCols);
		nMaxRow		= P.EndRow + 1;
		P.CurCol	= def % nNumCols;
		P.CurRow	= P.StartRow + def/nNumCols;
		picklist.add(P);
		return P;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
