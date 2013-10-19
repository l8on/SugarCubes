//----------------------------------------------------------------------------------------------------------------------------------
xyz			mMax, mCtr, mHalf;
int			NumApcRows = 5, NumApcCols = 8;
DGlobals 	DG = new DGlobals();

boolean btwn  	(int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
boolean btwn  	(double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}
float	interp 	(float a, float b, float c) { return (1-a)*b + a*c; }
float	randctr	(float a) { return random(a) - a*.5; }
float	min		(float a, float b, float c, float d) { return min(min(a,b),min(c,d)); }

float 	distToSeg	(float x, float y, float x1, float y1, float x2, float y2) {
	float A 			= x - x1, B = y - y1, C = x2 - x1, D = y2 - y1;
	float dot 			= A * C + B * D, len_sq	= C * C + D * D;
	float xx, yy,param 	= dot / len_sq;
	
	if (param < 0 || (x1 == x2 && y1 == y2)) { 	xx = x1; yy = y1; }
	else if (param > 1) {						xx = x2; yy = y2; }
	else {										xx = x1 + param * C;
												yy = y1 + param * D; }
	float dx = x - xx, dy = y - yy;
	return sqrt(dx * dx + dy * dy);
}


public class Pick {
	int 	NumPicks, Default	,	CurRow	, CurCol	,
			StartRow, EndRow	;
	String  tag		, Desc[]	;
	
	Pick	(String label, int _Def, int _Num, 	int nStart, String d[])	{
		NumPicks 	= _Num; 	Default = _Def; 
		StartRow 	= nStart;	EndRow	= StartRow + floor((NumPicks-1) / NumApcCols);
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
public class xyz {	float x,y,z;	// extends pVector; eliminate half of the functions
			xyz() {x=y=z=0;}
			xyz(Point p					  ) {x=p.x	; y=p.y; z=p.z;}
			xyz(xyz p					  ) {set(p);				 }
			xyz(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}
	void	set(Point p					  ) {x=p.x	; y=p.y; z=p.z;}
	void	set(xyz p					  ) {x=p.x	; y=p.y ; z=p.z ;}
	void	set(float _x,float _y,float _z) {x=_x	; y=_y	; z=_z	;}

	void	zoomX	(float zx) 				{x = x*zx - mMax.x*(zx-1)/2;				}
	void	zoomY	(float zy) 				{y = y*zy - mMax.y*(zy-1)/2;				}

	float	distance(xyz b)					{return dist(x,y,z,b.x,b.y,b.z); 	 	}
	float	distance(float _x, float _y)	{return dist(x,y,_x,_y); 	 			}
	float	dot     (xyz b)					{return x*b.x + y*b.y + z*b.z; 		 	}
	void	add		(xyz b)					{x += b.x; y += b.y; z += b.z;			}
	void	add		(float b)				{x += b  ; y += b  ; z += b  ;			}
	void	subtract(xyz b)					{x -= b.x; y -= b.y; z -= b.z;			}
	void	scale	(float b)				{x *= b  ; y *= b  ; z *= b  ;			}

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

	void	setRand	()						{ x = random(mMax.x); y = random(mMax.y); z = random(mMax.z); 	}
	void	setNorm	() 						{ x /= mMax.x; y /= mMax.y; z /= mMax.z; 						}
	void	interpolate(float i, xyz d)		{ x = interp(i,x,d.x); y = interp(i,y,d.y); z = interp(i,z,d.z); }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DGlobals {
	boolean		bInit			= false;
	MidiOutput 	APCOut			= null;
	MidiInput	APCIn			= null,		OxygenIn		= null;
	DPat		CurPat			= null;
	int			KeyPressed		= -1;
	boolean		bSustain 		= false;

	
	float		Sliders[] 		= new float [] {1,0,0,0,0,0,0,0};
	String  	SliderText[]	= new String[] {"Level", "??", "Spark", "Xwave", "Ywave", "??", "??", "??", "??"};
	
	void 		SetNoteOn	(int row, int col, int clr){ if (APCOut != null) APCOut.sendNoteOn		(col, row, clr); 	}
	void 		SetNoteOff 	(int row, int col, int clr){ if (APCOut != null) APCOut.sendNoteOff		(col, row, clr); 	}
	void 		SetKnob	 	(int cc , int c  , int v  ){ if (APCOut != null) APCOut.sendController	(cc , c, v); 		}

	DBool		GetBool (int i) 					{ return (DBool)CurPat.bools .get(i); }
	Pick 		GetPick (int i) 					{ return (Pick) CurPat.picks .get(i); }
	DParam 		GetParam(int i) 					{ return (DParam) CurPat.params.get(i); }

	float		_Level		()						{ return Sliders[0]; }
	float		_Spark		()						{ return Sliders[2]; }
	float		_XWave		()						{ return Sliders[3]; }
	float		_YWave		()						{ return Sliders[4]; }

	void		Init		() {
		if (bInit) return; bInit=true;
	    for (MidiOutputDevice o: RWMidi.getOutputDevices()) { if (o.toString().contains("APC")) { APCOut = o.createOutput(); break;}}
		for (MidiInputDevice  i: RWMidi.getInputDevices ()) { if (i.toString().contains("APC")) { i.createInput (this); 	 break;}}
	}
	
	boolean		isFocused  () 		{ return CurPat != null && CurPat == midiEngine.getFocusedDeck().getActivePattern(); }
	void		Deactivate (DPat p) { if (p != CurPat) return; uiDebugText.setText(""); CurPat = null;					 }
	void		Activate   (DPat p) {
		bSustain = false;
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
		for (int i=0; i<5; i++) 				  Text2 += SliderText[i]  + ": " + round(100*Sliders[i])  + "   ";
		uiDebugText.setText(Text1, Text2);
	}

	void 	UpdateLights() {
		if (!isFocused() || APCOut == null) return;
		for (int i=53;i< 58; i++) for (int j=0; j<NumApcCols; j++) SetNoteOn(i, j, 0);
		for (int i=48;i< 56; i++) SetKnob(0, i, 0);
		for (int i=16;i< 20; i++) SetKnob(0, i, 0);

		for (int i=0; i<CurPat.params.size(); i++) SetKnob		( 0, i<8 ? 48+i : 16 + i - 8, round(GetParam(i).Val()*127) );
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
		bSustain=false;
	}

	void noteOnReceived (Note note) { if (!isFocused()) return;
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<CurPat.picks.size(); i++) if (GetPick(i).set(row, col)) 	  return;
		for (int i=0; i<CurPat.bools.size(); i++) if (GetBool(i).set(row, col, true)) return;

		if (row == 84 && col==0) { Activate(CurPat); CurPat.StartPattern(); return; }
		if (row == 85 && col==0) { bSustain=true; return; }
		
		if (row == 52) { KeyPressed = col; return; }
		println("row: " + row + "  col:   " + col);
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DPat extends SCPattern
{
	ArrayList 	picks	 	= new ArrayList(); // should be ArrayList<Pick> picks = new ArrayList<Pick>();
	ArrayList 	params 		= new ArrayList();
	ArrayList 	bools		= new ArrayList();
	int			nMaxRow  	= 53;
	float		LastQuant	= -1, LastJog = -1;
	float[]		xWaveNz, yWaveNz;
	int 		nPoint	, nPoints;
	xyz			xyzJog = new xyz(), vT1 = new xyz(), vT2 = new xyz();
	xyz			modmin;

	float		NoiseMove	= random(10000);
	DParam		pBlank, pBlank2, pRotX, pRotY, pRotZ, pSpin, pTransX, pTransY;

	DBool		pXsym, pYsym, pRsym, pXdup, pXtrip, pJog, pKey;
	float		lxh		() 							{ return lx.getBaseHuef(); 					}
	float		Dist	 (xyz a, xyz b) 			{ return dist(a.x,a.y,a.z,b.x,b.y,b.z); 	}
	int			c1c		 (float a) 					{ return round(100*constrain(a,0,1));		}
	float 		interpWv(float i, float[] vals) 	{ return interp(i-floor(i), vals[floor(i)], vals[ceil(i)]); }

	float 		CalcCone (xyz v1, xyz v2, xyz c) 	{ vT1.set(v1); vT2.set(v2); vT1.subtract(c); vT2.subtract(c);
														return degrees( acos ( vT1.dot(vT2) / (sqrt(vT1.dot(vT1)) * sqrt(vT2.dot(vT2)) ) ));	}

	void  		StartPattern() 						{								}
	void  		StartRun(double deltaMs) 			{								}
	color		CalcPoint(xyz p) 					{ return lx.hsb(0,0,0); 		}
	boolean		IsActive()							{ return this == DG.CurPat;												}
	boolean		IsFocused()							{ return midiEngine != null && midiEngine.getFocusedDeck() != null &&
															 this == midiEngine.getFocusedDeck().getActivePattern();		}
	void 		onInactive() 						{ UpdateState(); }
	void 		onActive  () 						{ UpdateState(); StartPattern(); }
	void 		UpdateState() 						{ if (IsFocused() != IsActive()) { if (IsFocused()) DG.Activate(this); else DG.Deactivate(this); } }
	color		blend3(color c1, color c2, color c3){ return blendColor(c1,blendColor(c2,c3,ADD),ADD);						}

	DParam		addParam(String label, double value) {
		DParam P = new DParam(label, value);
		super.addParameter(P);
		params.add(P); return P;
	}

	Pick addPick(String name, int def, int _max, String[] desc) {
		Pick P 		= new Pick(name, def, _max+1, nMaxRow, desc); 
		nMaxRow		= P.EndRow + 1;
		picks.add(P);
		return P;
	}

	DPat(GLucose glucose) {
		super(glucose);

		pBlank		=	addParam("",  0);
		pBlank2		=	addParam("" , .5);
		pTransX		=	addParam("TrnX", .5);
		pTransY		=	addParam("TrnY", .5);
		pRotX 		= 	addParam("RotX", .5);
		pRotY 		= 	addParam("RotY", .5);
		pRotZ 		= 	addParam("RotZ", .5);
		pSpin		= 	addParam("Spin", .5);

		nPoints 	=	model.points.size();
		pXsym 		=	new DBool("X-SYM", false, 49, 0);	bools.add(pXsym	);
		pYsym 		=	new DBool("Y-SYM", false, 49, 1);	bools.add(pYsym	);
		pRsym 		=	new DBool("R-SYM", false, 49, 2);	bools.add(pRsym );
		pXdup		=	new DBool("X-DUP", false, 49, 3);	bools.add(pXdup );
		pJog		=	new DBool("JOG"  , false, 49, 4);	bools.add(pJog	);
		pKey		=	new DBool("KBD"	 , false, 49, 5);	bools.add(pKey	);

		modmin		=	new xyz(model.xMin, model.yMin, model.zMin);
		mMax		= 	new xyz(model.xMax, model.yMax, model.zMax); mMax.subtract(modmin);
		mCtr		= 	new xyz(mMax); mCtr.scale(.5);
		mHalf		= 	new xyz(.5,.5,.5);
		xWaveNz		=	new float[ceil(mMax.y)+1];
		yWaveNz		=	new float[ceil(mMax.x)+1];

		//println (model.xMin + " " + model.yMin + " " +  model.zMin);
		//println (model.xMax + " " + model.yMax + " " +  model.zMax);
		DG.Init();
	}

	void run(double deltaMs)
	{
		UpdateState();
		NoiseMove   	+= deltaMs; NoiseMove = NoiseMove % 1e7;
		StartRun		(deltaMs);
		xyz P 			= new xyz(), tP = new xyz(), pSave = new xyz();
		xyz pTrans 		= new xyz(pTransX.Val()*200-100, pTransY.Val()*100-50,0);
		
		DG.SetText();
		nPoint 	= 0;

		if (pJog.b) {
			float tRamp	= (lx.tempo.rampf() % .25);
			if (tRamp < LastJog) xyzJog.set(randctr(mMax.x*.2), randctr(mMax.y*.2), randctr(mMax.z*.2));
			LastJog = tRamp; 
		}

		// precalculate this stuff
		float yWv = DG._YWave(), xWv = DG._XWave(), sprk = DG._Spark();
		if (yWv > 0) for (int i=0; i<ceil(mMax.x)+1; i++)
			yWaveNz[i] = yWv * (noise(i/(mMax.x*.3)-(2e3+NoiseMove)/1500.) - .5) * (mMax.y/2.);

		if (xWv > 0) for (int i=0; i<ceil(mMax.y)+1; i++)
			xWaveNz[i] = xWv * (noise(i/(mMax.y*.3)-(1e3+NoiseMove)/1500.) - .5) * (mMax.x/2.);

		for (Point p : model.points) { nPoint++;
			P.set(p);
			P.subtract(modmin);
			P.subtract(pTrans);
			if (sprk > 0) {	P.y += sprk*randctr(50); P.x += sprk*randctr(50); P.z += sprk*randctr(50); }
			if (yWv > 0) 	P.y += interpWv(p.x-modmin.x, yWaveNz);
			if (xWv > 0) 	P.x += interpWv(p.y-modmin.y, xWaveNz);
			if (pJog.b)		P.add(xyzJog);


			color cNew, cOld = colors[p.index];
							{ tP.set(P); 				  					cNew = CalcPoint(tP);							}
 			if (pXsym.b)	{ tP.set(mMax.x-P.x,P.y,P.z); 					cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pYsym.b) 	{ tP.set(P.x,mMax.y-P.y,P.z); 					cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pRsym.b) 	{ tP.set(mMax.x-P.x,mMax.y-P.y,mMax.z-P.z);		cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pXdup.b) 	{ tP.set((P.x+mMax.x*.5)%mMax.x,P.y,P.z);		cNew = blendColor(cNew, CalcPoint(tP), ADD);	}

			float 								s =	lx.s(cNew);
			float 								b = lx.b(cNew)/100.;
			if (DG.bSustain == true) 			b = max(b, (float) (lx.b(cOld)/100.));

			colors[p.index] = lx.hsb(lx.h(cNew), s, 100 *  b * DG._Level());
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
class dTurn { 
	dVertex v; 
	int pos0, pos1;
	dTurn(int _pos0, dVertex _v, int _pos1) { v = _v; pos0 = _pos0; pos1 = _pos1; }
}

class dVertex {
	dVertex c0, c1, 		// connections on the cube
			opp, same;		// opp - same strip, opp direction
							// same - same strut, diff strip, dir
	dTurn 	t0, t1;
	dStrip  s;
	int 	dir, ci;	// dir -- 1 or -1.
						// ci  -- color index

	dVertex(dStrip _s, Point _p) { s = _s; ci  = _p.index; }
	Point 	getPoint(int i) 	 { return s.s.points.get(dir>0 ? i : 15-i);  }
	void 	setOpp(dVertex _opp) { opp = _opp; dir = (ci < opp.ci ? 1 : -1); }
}

class dStrip  {
	dVertex v0, v1;
	int 	row, col;
	Strip 	s;
	String 	desc() { return "r:" + row + " c:" + col + "i:" + floor(v0.ci/16); }
	dStrip(Strip _s, int _i, int _row, int _col)  { s = _s; row = _row; col = _col; }
}
//----------------------------------------------------------------------------------------------------------------------------------
float PointDist(Point p1, Point p2) { return dist(p1.x,p1.y,p1.z,p2.x,p2.y,p2.z); }

class dPixel   { dVertex v; int pos; dPixel(dVertex _v, int _pos) { v=_v; pos=_pos; } }
class dLattice {
	private 	int iTowerStrips=0;

	dStrip[] 	DS = new dStrip[glucose.model.strips.size()];
	//int[][]  	DQ = new int[NumBackTowers][MaxCubeHeight*2];
	//dStrip  GetStrip (int row, int col, int off) { 
	//	return (!btwn(off,0,15) || !btwn(row,0,MaxCubeHeight*2-1) || !btwn(col,0,NumBackTowers-1) || DQ[col][row]<0) ? null : 
	//			DS[DQ[col][row]+off]; 
	//}

	void	addTurn(dVertex v0, int pos0, dVertex v1, int pos1) {	dTurn t = new dTurn(pos0, v1, pos1); if (v0.t0 == null) v0.t0=t; else v0.t1=t; }
	float   Dist2	 (Strip s1, int pos1, Strip s2, int pos2) 	{ 	return PointDist(s1.points.get(pos1), s2.points.get(pos2)); }
	float   PD2 	 (Point p1, float x, float y, float z) 		{ 	return dist(p1.x,p1.y,p1.z,x,y,z); }
	boolean SameSame (Strip s1, Strip s2) 						{	return max(Dist2(s1, 0, s2, 0), Dist2(s1,15, s2,15)) < 5 ;	}	// same strut, same direction
	boolean SameOpp  (Strip s1, Strip s2) 						{	return max(Dist2(s1, 0, s2,15), Dist2(s1,15, s2,0 )) < 5 ;	}	// same strut, opp direction
	boolean SameBar  (Strip s1, Strip s2) 						{	return SameSame(s1,s2) || SameOpp(s1,s2);					}	// 2 strips on same strut
	void 	AddJoint (dVertex v1, dVertex v2) {
		// should probably replace parallel but further with the new one
		if (v1.c0 != null && SameBar(v2.s.s, v1.c0.s.s)) return;
		if (v1.c1 != null && SameBar(v2.s.s, v1.c1.s.s)) return;
		if 		(v1.c0 == null) v1.c0 = v2; 
		else if (v1.c1 == null) v1.c1 = v2; 
	}

	dPixel getRand() 											{ 	return new dPixel(DS[floor(random(iTowerStrips))].v0,floor(random(15))); }
	dPixel getClosest(xyz p) {
		dVertex v = null; int pos=0; float d = 500;
		for (int j=0; j<iTowerStrips; j++) {
			dStrip s = DS[j];
			float nd = PD2(s.s.points.get(0),p.x,p.y,p.z); if (nd < d) { v=s.v0; d=nd; pos=0; }
			if (nd > 30) continue;
			for (int k=0; k<=15; k++) {
				nd = PD2(s.s.points.get(k),p.x,p.y,p.z); if (nd < d) { v = s.v0; d=nd; pos=k; }
			}
		}
		return random(2) < 1 ? new dPixel(v,pos) : new dPixel(v.opp,15-pos);
	}

	dLattice() {
		lattice=this;
		//for (int i=0;i<NumBackTowers;i++) for (int j=0;j<MaxCubeHeight*2;j++) DQ[i][j]=-1;

		int   col = 0, row = -2, i=-1;
		for (Strip strip : glucose.model.strips  ) { i++;
			if (i % 16 == 0) row+=2;
			if (row >= MaxCubeHeight*2-1) { col++; row = (col%2==1)?1:0; }	// only include lattice parts!
			iTowerStrips++;
			dStrip s = DS[iTowerStrips-1] = new dStrip(strip, iTowerStrips-1, row, col);
			s.v0 = new dVertex(s,strip.points.get(0 ));
			s.v1 = new dVertex(s,strip.points.get(15));
			s.v0.setOpp(s.v1); s.v1.setOpp(s.v0);
			//if (col < NumBackTowers) DQ[col][row] = 16*floor((iTowerStrips-1)/16);
			//else s.row=-1;
		}

		for (int j=0; j<iTowerStrips; j++) { for (int k=j+1; k<iTowerStrips; k++) { 
			dStrip s1 = DS[j], s2 = DS[k];
			int c=0;
			if (SameSame(s1.s,s2.s)) {	s1.v0.same = s2.v0; s1.v1.same = s2.v1;
										s2.v0.same = s1.v0; s2.v1.same = s1.v1; continue; } // parallel
			if (SameOpp (s1.s,s2.s)) {	s1.v0.same = s2.v1; s1.v1.same = s2.v0;
										s2.v0.same = s1.v1; s2.v1.same = s1.v0; continue; } // parallel
			if (Dist2(s1.s, 0, s2.s, 0) < 5) { c++; AddJoint(s1.v1, s2.v0); AddJoint(s2.v1, s1.v0); }
			if (Dist2(s1.s, 0, s2.s,15) < 5) { c++; AddJoint(s1.v1, s2.v1); AddJoint(s2.v0, s1.v0); }
			if (Dist2(s1.s,15, s2.s, 0) < 5) { c++; AddJoint(s1.v0, s2.v0); AddJoint(s2.v1, s1.v1); }
			if (Dist2(s1.s,15, s2.s,15) < 5) { c++; AddJoint(s1.v0, s2.v1); AddJoint(s2.v0, s1.v1); }
			if (c>0) continue;

			// Are they touching at all?
			int pos1=0, pos2=0; float d = 100;

			while (pos1 < 15 || pos2 < 15) {
				float oldD = d;
				if (pos1<15) { float d2 = Dist2(s1.s, pos1+1, s2.s, pos2+0); if (d2 < d) { d=d2; pos1++; } }
				if (pos2<15) { float d2 = Dist2(s1.s, pos1+0, s2.s, pos2+1); if (d2 < d) { d=d2; pos2++; } }
				if (d > 50  || oldD == d) break ;
			}

			if (d>5) continue;
			addTurn(s1.v0, pos1, s2.v0, pos2); addTurn(s1.v1, 15-pos1, s2.v0, pos2); 
			addTurn(s2.v0, pos2, s1.v0, pos1); addTurn(s2.v1, 15-pos2, s1.v0, pos1);

		}}
	}
}

dLattice lattice;
//----------------------------------------------------------------------------------------------------------------------------------
