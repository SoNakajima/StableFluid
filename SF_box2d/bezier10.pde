
class Bezier10 {

  PVector[] P;
  PVector[] R;
  int tn;
  int[] C = {
    1, 10, 45, 120, 210, 252, 210, 120, 45, 10, 1
  };

  Bezier10(PVector[] _P) {
    P = new PVector[_P.length];
    for (int i=0; i<_P.length; i++) {
      P[i] = new PVector();
      P[i].x = _P[i].x;
      P[i].y = _P[i].y;
    }

    tn =100;
    R = new PVector[tn+1];
  }

  void draw(PVector[] _P) {

    int tt;
    float t = 0.0;
    float ts = (float)1/tn;
    float[] B = new float[P.length];

    for (int i=0; i<_P.length; i++) {
      P[i] = new PVector();
      P[i].x = _P[i].x;
      P[i].y = _P[i].y;
    }

    noFill();
    stroke(255);
    strokeWeight(6);

    for (int i=0; i<size; i++) {
      object[i] = false;
    }

    for (tt = 0; tt<tn+1; tt+=1) {
      for (int i=0; i<11; i++) {
        int n = 10;
        B[i]= C[i]*pow(t, i)*pow(1-t, n-i);
      }
      R[tt] = new PVector(0, 0);
      for (int i=0; i<11; i++) {
        R[tt].x += B[i]*P[i].x;
        R[tt].y += B[i]*P[i].y;
      }
      if (tt != 0) line(R[tt-1].x, R[tt-1].y, R[tt].x, R[tt].y);

      object[IX((int)(R[tt].x/width*N), (int)(R[tt].y/height*N))] = true;
      object[IX((int)(R[tt].x/width*N), (int)(R[tt].y/height*N)-1)] = true;
      object[IX((int)(R[tt].x/width*N)-1, (int)(R[tt].y/height*N)-1)] = true;
      object[IX((int)(R[tt].x/width*N)+1, (int)(R[tt].y/height*N)-1)] = true;
      object[IX((int)(R[tt].x/width*N), (int)(R[tt].y/height*N)+1)] = true;
      object[IX((int)(R[tt].x/width*N)-1, (int)(R[tt].y/height*N)+1)] = true;
      object[IX((int)(R[tt].x/width*N)+1, (int)(R[tt].y/height*N)+1)] = true;      
      object[IX((int)(R[tt].x/width*N)-1, (int)(R[tt].y/height*N))] = true;
      object[IX((int)(R[tt].x/width*N)+1, (int)(R[tt].y/height*N))] = true;

      t = t + ts;
    }
  }
}

