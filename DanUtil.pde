//----------------------------------------------------------------------------------------------------------------------------------
int			NumApcRows=4, NumApcCols=8;

boolean btwn  	(int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
boolean btwn  	(double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}
float	interp 	(float a, float b, float c) { return (1-a)*b + a*c; }
float	randctr	(float a) { return random(a) - a*.5; }
float	min		(float a, float b, float c, float d) { return min(min(a,b),min(c,d)); 	}
float   pointDist(Point p1, Point p2) { return dist(p1.x,p1.y,p1.z,p2.x,p2.y,p2.z); 	}
float   xyDist   (Point p1, Point p2) { return dist(p1.x,p1.y,p2.x,p2.y); 				}
float 	distToSeg(float x, float y, float x1, float y1, float x2, float y2) {
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
	int 	NumPicks, Default	,	
			CurRow	, CurCol	,
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
//----------------------------------------------------------------------------------------------------------------------------------
public class DPat extends SCPattern
{
	ArrayList<Pick>   picks  = new ArrayList<Pick>  ();
	ArrayList<DBool>  bools  = new ArrayList<DBool> ();

	PVector		mMax, mCtr, mHalf;

	MidiOutput  APCOut;
	int			nMaxRow  	= 53;
	float		LastJog = -1;
	float[]		xWaveNz, yWaveNz;
	int 		nPoint	, nPoints;
	PVector		xyzJog = new PVector(), modmin;

	float			NoiseMove	= random(10000);
	BasicParameter	pSpark, pWave, pRotX, pRotY, pRotZ, pSpin, pTransX, pTransY;
	DBool			pXsym, pYsym, pRsym, pXdup, pXtrip, pJog, pGrey;

	float		lxh		() 									{ return lx.getBaseHuef(); 											}
	int			c1c		 (float a) 							{ return round(100*constrain(a,0,1));								}
	float 		interpWv(float i, float[] vals) 			{ return interp(i-floor(i), vals[floor(i)], vals[ceil(i)]); 		}
	void 		setNorm (PVector vec)						{ vec.set(vec.x/mMax.x, vec.y/mMax.y, vec.z/mMax.z); 				}
	void		setRand	(PVector vec)						{ vec.set(random(mMax.x), random(mMax.y), random(mMax.z)); 			}
	void		setVec 	(PVector vec, Point p)				{ vec.set(p.x, p.y, p.z);  											}
	void		interpolate(float i, PVector a, PVector b)	{ a.set(interp(i,a.x,b.x), interp(i,a.y,b.y), interp(i,a.z,b.z)); 	}
	void  		StartRun(double deltaMs) 					{ }
	float 		val		(BasicParameter p) 					{ return p.getValuef();												}
	color		CalcPoint(PVector p) 						{ return lx.hsb(0,0,0); 											}
	color		blend3(color c1, color c2, color c3)		{ return blendColor(c1,blendColor(c2,c3,ADD),ADD); 					}

	void	rotateZ (PVector p, PVector o, float nSin, float nCos) { p.set(    nCos*(p.x-o.x) - nSin*(p.y-o.y) + o.x    , nSin*(p.x-o.x) + nCos*(p.y-o.y) + o.y,p.z); }
	void	rotateX (PVector p, PVector o, float nSin, float nCos) { p.set(p.x,nCos*(p.y-o.y) - nSin*(p.z-o.z) + o.y    , nSin*(p.y-o.y) + nCos*(p.z-o.z) + o.z    ); }
	void	rotateY (PVector p, PVector o, float nSin, float nCos) { p.set(    nSin*(p.z-o.z) + nCos*(p.x-o.x) + o.x,p.y, nCos*(p.z-o.z) - nSin*(p.x-o.x) + o.z    ); }

	BasicParameter	addParam(String label, double value) 	{ BasicParameter p = new BasicParameter(label, value); addParameter(p); return p; }

	PVector 	vT1 = new PVector(), vT2 = new PVector();
	float 		calcCone (PVector v1, PVector v2, PVector c) 	{	vT1.set(v1); vT2.set(v2); vT1.sub(c); vT2.sub(c);
																	return degrees(PVector.angleBetween(vT1,vT2)); }

	Pick 		addPick(String name, int def, int _max, String[] desc) {
		Pick P 		= new Pick(name, def, _max+1, nMaxRow, desc); 
		nMaxRow		= P.EndRow + 1;
		picks.add(P);
		return P;
	}

    boolean 	noteOff(Note note) {
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<bools.size(); i++) if (bools.get(i).set(row, col, false)) { presetManager.dirty(this); return true; }
		updateLights(); return false;
	}

    boolean 	noteOn(Note note) {
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<picks.size(); i++) if (picks.get(i).set(row, col)) 	  		{ presetManager.dirty(this); return true; }
		for (int i=0; i<bools.size(); i++) if (bools.get(i).set(row, col, true)) 	{ presetManager.dirty(this); return true; }
		println("row: " + row + "  col:   " + col); return false;
	}

	void 		onInactive() 			{ uiDebugText.setText(""); }
	void 		onReset() 				{
		for (int i=0; i<bools .size(); i++) bools.get(i).reset();
		for (int i=0; i<picks .size(); i++) picks.get(i).reset();
		presetManager.dirty(this); 
		updateLights(); 
	}

	DPat(GLucose glucose) {
		super(glucose);

		pSpark		=	addParam("Sprk",  0);
		pWave		=	addParam("Wave",  0);
		pTransX		=	addParam("TrnX", .5);
		pTransY		=	addParam("TrnY", .5);
		pRotX 		= 	addParam("RotX", .5);
		pRotY 		= 	addParam("RotY", .5);
		pRotZ 		= 	addParam("RotZ", .5);
		pSpin		= 	addParam("Spin", .5);

		nPoints 	=	model.points.size();
		pXsym 		=	new DBool("X-SYM", false, 48, 0);	bools.add(pXsym	);
		pYsym 		=	new DBool("Y-SYM", false, 48, 1);	bools.add(pYsym	);
		pRsym 		=	new DBool("R-SYM", false, 48, 2);	bools.add(pRsym );
		pXdup		=	new DBool("X-DUP", false, 48, 3);	bools.add(pXdup );
		pJog		=	new DBool("JOG"  , false, 48, 4);	bools.add(pJog	);
		pGrey		=	new DBool("GREY" , false, 48, 5);	bools.add(pGrey );

		modmin		=	new PVector(model.xMin, model.yMin, model.zMin);
		mMax		= 	new PVector(model.xMax, model.yMax, model.zMax); mMax.sub(modmin);
		mCtr		= 	new PVector(); mCtr.set(mMax); mCtr.mult(.5);
		mHalf		= 	new PVector(.5,.5,.5);
		xWaveNz		=	new float[ceil(mMax.y)+1];
		yWaveNz		=	new float[ceil(mMax.x)+1];

		//println (model.xMin + " " + model.yMin + " " +  model.zMin);
		//println (model.xMax + " " + model.yMax + " " +  model.zMax);
	  //for (MidiOutputDevice o: RWMidi.getOutputDevices()) { if (o.toString().contains("APC")) { APCOut = o.createOutput(); break;}}
	}

	float spin() {
	  float raw = val(pSpin);
	  if (raw <= 0.45) {
	    return raw + 0.05;
	  } else if (raw >= 0.55) {
	    return raw - 0.05;
    }
    return 0.5;
	}
	
	void setAPCOutput(MidiOutput output) {
	  APCOut = output;
	}

	void updateLights() { if (APCOut == null) return;
	    for (int i = 0; i < NumApcRows; ++i) 
	    	for (int j = 0; j < 8; ++j) 		APCOut.sendNoteOn(j, 53+i,  0);
		for (int i=0; i<picks .size(); i++) 	APCOut.sendNoteOn(picks.get(i).CurCol, picks.get(i).CurRow, 3);
		for (int i=0; i<bools .size(); i++) 	if (bools.get(i).b) 	APCOut.sendNoteOn	(bools.get(i).col, bools.get(i).row, 1);
												else					APCOut.sendNoteOff	(bools.get(i).col, bools.get(i).row, 0);
	}

	void run(double deltaMs)
	{
		if (deltaMs > 100) return;

		if (this == midiEngine.getFocusedDeck().getActivePattern()) {
			String Text1="", Text2="";
			for (int i=0; i<bools.size(); i++) if (bools.get(i).b) Text1 += " " + bools.get(i).tag       + "   ";
			for (int i=0; i<picks.size(); i++) Text1 += picks.get(i).tag + ": " + picks.get(i).CurDesc() + "   ";
			uiDebugText.setText(Text1, Text2);
		}

		NoiseMove   	+= deltaMs; NoiseMove = NoiseMove % 1e7;
		StartRun		(deltaMs);
		PVector P 		= new PVector(), tP = new PVector(), pSave = new PVector();
		PVector pTrans 	= new PVector(val(pTransX)*200-100, val(pTransY)*100-50,0);
		nPoint 	= 0;

		if (pJog.b) {
			float tRamp	= (lx.tempo.rampf() % .25);
			if (tRamp < LastJog) xyzJog.set(randctr(mMax.x*.2), randctr(mMax.y*.2), randctr(mMax.z*.2));
			LastJog = tRamp; 
		}

		// precalculate this stuff
		float wvAmp = val(pWave), sprk = val(pSpark);
		if (wvAmp > 0) {
			for (int i=0; i<ceil(mMax.x)+1; i++)
				yWaveNz[i] = wvAmp * (noise(i/(mMax.x*.3)-(2e3+NoiseMove)/1500.) - .5) * (mMax.y/2.);

			for (int i=0; i<ceil(mMax.y)+1; i++)
				xWaveNz[i] = wvAmp * (noise(i/(mMax.y*.3)-(1e3+NoiseMove)/1500.) - .5) * (mMax.x/2.);
		}

		for (Point p : model.points) { nPoint++;
			setVec(P,p);
			P.sub(modmin);
			P.sub(pTrans);
			if (sprk  > 0) {P.y += sprk*randctr(50); P.x += sprk*randctr(50); P.z += sprk*randctr(50); }
			if (wvAmp > 0) 	P.y += interpWv(p.x-modmin.x, yWaveNz);
			if (wvAmp > 0) 	P.x += interpWv(p.y-modmin.y, xWaveNz);
			if (pJog.b)		P.add(xyzJog);


			color cNew, cOld = colors[p.index];
							{ tP.set(P); 				  					cNew = CalcPoint(tP);							}
 			if (pXsym.b)	{ tP.set(mMax.x-P.x,P.y,P.z); 					cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pYsym.b) 	{ tP.set(P.x,mMax.y-P.y,P.z); 					cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pRsym.b) 	{ tP.set(mMax.x-P.x,mMax.y-P.y,mMax.z-P.z);		cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pXdup.b) 	{ tP.set((P.x+mMax.x*.5)%mMax.x,P.y,P.z);		cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pGrey.b)	{ cNew = lx.hsb(0, 0, lx.b(cNew)); }
			colors[p.index] = cNew;
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
	dVertex c0, c1, c2, c3, 	// connections on the cube
			opp, same;			// opp - same strip, opp direction
								// same - same strut, diff strip, dir
	dTurn 	t0, t1, t2, t3;
	Strip   s;
	int 	dir, ci;		// dir -- 1 or -1.
							// ci  -- color index

	dVertex(Strip _s, Point _p)  { s = _s; ci  = _p.index; }
	Point 	getPoint(int i) 	 { return s.points.get(dir>0 ? i : 15-i);  }
	void 	setOpp(dVertex _opp) { opp = _opp; dir = (ci < opp.ci ? 1 : -1); }
}
//----------------------------------------------------------------------------------------------------------------------------------
class dPixel   { dVertex v; int pos; dPixel(dVertex _v, int _pos) { v=_v; pos=_pos; } }
class dLattice {
	void	addTurn  (dVertex v0, int pos0, dVertex v1, int pos1) {	dTurn t = new dTurn(pos0, v1, pos1); 
																	if (v0.t0 == null) { v0.t0=t; return; }
																	if (v0.t1 == null) { v0.t1=t; return; }
																	if (v0.t2 == null) { v0.t2=t; return; }
																	if (v0.t3 == null) { v0.t3=t; return; }
																}
	float   dist2	 (Strip s1, int pos1, Strip s2, int pos2) 	{ 	return pointDist(s1.points.get(pos1), s2.points.get(pos2)); }
	float   pd2 	 (Point p1, float x, float y, float z) 		{ 	return dist(p1.x,p1.y,p1.z,x,y,z); }
	boolean sameSame (Strip s1, Strip s2) 						{	return max(dist2(s1, 0, s2, 0), dist2(s1,15, s2,15)) < 5 ;	}	// same strut, same direction
	boolean sameOpp  (Strip s1, Strip s2) 						{	return max(dist2(s1, 0, s2,15), dist2(s1,15, s2,0 )) < 5 ;	}	// same strut, opp direction
	boolean sameBar  (Strip s1, Strip s2) 						{	return sameSame(s1,s2) || sameOpp(s1,s2);					}	// 2 strips on same strut


	void 	addJoint (dVertex v1, dVertex v2) {
		// should probably replace parallel but further with the new one
		if (v1.c0 != null && sameBar(v2.s, v1.c0.s)) return;
		if (v1.c1 != null && sameBar(v2.s, v1.c1.s)) return;
		if (v1.c2 != null && sameBar(v2.s, v1.c2.s)) return;
		if (v1.c3 != null && sameBar(v2.s, v1.c3.s)) return;

		if 		(v1.c0 == null) v1.c0 = v2; 
		else if (v1.c1 == null) v1.c1 = v2; 
		else if (v1.c2 == null) v1.c2 = v2; 
		else if (v1.c3 == null) v1.c3 = v2;
	}

	dVertex v0(Strip s) { return (dVertex)s.obj1; }
	dVertex v1(Strip s) { return (dVertex)s.obj2; }

	dPixel getClosest(PVector p) {
		dVertex v = null; int pos=0; float d = 500;

		for (Strip s : glucose.model.strips) {
			float nd = pd2(s.points.get(0),p.x,p.y,p.z); if (nd < d) { v=v0(s); d=nd; pos=0; }
			if (nd > 30) continue;
			for (int k=0; k<=15; k++) {
				nd = pd2(s.points.get(k),p.x,p.y,p.z); if (nd < d) { v =v0(s); d=nd; pos=k; }
			}
		}
		return random(2) < 1 ? new dPixel(v,pos) : new dPixel(v.opp,15-pos);
	}

	dLattice() {
		lattice=this;

		for (Strip s  : glucose.model.strips) {
			dVertex vrtx0 = new dVertex(s,s.points.get(0 )); s.obj1=vrtx0;
			dVertex vrtx1 = new dVertex(s,s.points.get(15)); s.obj2=vrtx1;
			vrtx0.setOpp(vrtx1); vrtx1.setOpp(vrtx0);
		}

		for (Strip s1 : glucose.model.strips) { for (Strip s2 : glucose.model.strips) {
			if (s1.points.get(0).index < s2.points.get(0).index) continue;
			int c=0;
			if (sameSame(s1,s2)) 	{	v0(s1).same = v0(s2); v1(s1).same = v1(s2);
										v0(s2).same = v0(s1); v1(s2).same = v1(s1); continue; } // parallel
			if (sameOpp (s1,s2)) 	{	v0(s1).same = v1(s2); v1(s1).same = v0(s2);
										v0(s2).same = v1(s1); v1(s2).same = v0(s1); continue; } // parallel
			if (dist2(s1, 0, s2, 0) < 5) { c++; addJoint(v1(s1), v0(s2)); addJoint(v1(s2), v0(s1)); }
			if (dist2(s1, 0, s2,15) < 5) { c++; addJoint(v1(s1), v1(s2)); addJoint(v0(s2), v0(s1)); }
			if (dist2(s1,15, s2, 0) < 5) { c++; addJoint(v0(s1), v0(s2)); addJoint(v1(s2), v1(s1)); }
			if (dist2(s1,15, s2,15) < 5) { c++; addJoint(v0(s1), v1(s2)); addJoint(v0(s2), v1(s1)); }
			if (c>0) continue;

			// Are they touching at all?
			int pos1=0, pos2=0; float d = 100;

			while (pos1 < 15 || pos2 < 15) {
				float oldD = d;
				if (pos1<15) { float d2 = dist2(s1, pos1+1, s2, pos2+0); if (d2 < d) { d=d2; pos1++; } }
				if (pos2<15) { float d2 = dist2(s1, pos1+0, s2, pos2+1); if (d2 < d) { d=d2; pos2++; } }
				if (d > 50  || oldD == d) break ;
			}

			if (d>5) continue;
			addTurn(v0(s1), pos1, v0(s2), pos2); addTurn(v1(s1), 15-pos1, v0(s2), pos2); 
			addTurn(v0(s2), pos2, v0(s1), pos1); addTurn(v1(s2), 15-pos2, v0(s1), pos1);
		}}
	}
}

dLattice lattice;
//----------------------------------------------------------------------------------------------------------------------------------
