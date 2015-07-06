class BezierCurve {

  PVector P0, P1, P2, P3;
  PVector[] R;  //choutenn no hairetu
  int tn;

  BezierCurve(int _P0x,int _P0y,int _P1x,int _P1y,int _P2x,int _P2y,int _P3x,int _P3y){ 
    P0 = new PVector(); 
    P0.x =  _P0x; 
    P0.y = _P0y;
    P1 = new PVector(); 
    P1.x = _P1x; 
    P1.y = _P1y;
    P2 = new PVector(); 
    P2.x = _P2x; 
    P2.y = _P2y;
    P3 = new PVector(); 
    P3.x = _P3x; 
    P3.y = _P3y;

    tn = 100;  // not to use float 
    R = new PVector[tn+1];
  }

  void draw() {

    int   tt;
    float t=0.0;
    float ts = (float)1 / tn; 
    float B30t, B31t, B32t, B33t;

  for (int i=0; i<size; i++) {
    object[i] = false;
  } 
  
  
  
    for (tt = 0; tt < tn+1; tt+=1) {
      B30t = (1-t)*(1-t)*(1-t) ; 
      B31t = 3*(1-t)*(1-t)*t ;
      B32t = 3*(1-t)*t*t ; 
      B33t = t*t*t ;
      R[tt] = new PVector();
      R[tt].x = B30t*P0.x + B31t*P1.x + B32t*P2.x + B33t*P3.x ;
      R[tt].y = B30t*P0.y + B31t*P1.y + B32t*P2.y + B33t*P3.y ;   

      object[IX((int)(R[tt].x/width*N), (int)(R[tt].y/height*N))] = true;
      object[IX((int)(R[tt].x/width*N), (int)(R[tt].y/height*N)-1)] = true;
      object[IX((int)(R[tt].x/width*N)-1, (int)(R[tt].y/height*N)-1)] = true;
      object[IX((int)(R[tt].x/width*N)+1, (int)(R[tt].y/height*N)-1)] = true;
      object[IX((int)(R[tt].x/width*N), (int)(R[tt].y/height*N)+1)] = true;
      object[IX((int)(R[tt].x/width*N)-1, (int)(R[tt].y/height*N)+1)] = true;
      object[IX((int)(R[tt].x/width*N)+1, (int)(R[tt].y/height*N)+1)] = true;      
      object[IX((int)(R[tt].x/width*N)-1, (int)(R[tt].y/height*N))] = true;
      object[IX((int)(R[tt].x/width*N)+1, (int)(R[tt].y/height*N))] = true;
      t = t + ts; //0.01 dutu 100kai
    }
  }
}

