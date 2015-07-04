void draw_Speed() {

  float x, y, h, s;

  h = 1.0f/ (float)N;

  for (int i=0; i<=N; i++) {
    x = (i-0.5f)*h;
    for (int j=0; j<=N; j++) {
      y = (j-0.5f)*h;

      s = (u[IX(i, j)]*u[IX(i, j)]+v[IX(i, j)]*v[IX(i, j)]);
      s *= 500000;

       s = log(s)*30;
       
       colorMode(HSB);

       stroke(s,255,s+50);
       fill(s,255,s+50);  

      rect(x*width, y*height, h*width, h*height);
    }
  }
}

