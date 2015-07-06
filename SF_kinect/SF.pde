
int IX(int i,int j){
  return (i + (N+2)* j); 
}

void SWAP(float[] x0,float[] x){

  float[] temp = x0;
  for(int i=0;i<size;i++){
    temp[i] = x0[i];
    x0[i] = x[i];
    x[i] = temp[i];
  }
} 


void add_source(int N, float[] x, float[] s, float dt){  
  for(int i=0; i<size; i++){ x[i] += dt*s[i]; }
}

void set_bnd(int N, int b, float[] x){
  
  for(int i=1;i<=N;i++){
    for(int j=1;j<=N;j++){
      if(object[IX(i,j)]){
            if ( b == 1 ) {
            // inverse horizontal velocity at vertical object border
            if ( ! object[IX(i-1, j)]) x[IX(i, j)] =  -x[IX(i-1, j)];
            if ( ! object[IX(i+1, j)]) x[IX(i, j)] =  -x[IX(i+1, j)];
          } 
          else if ( b == 2 ) {
            // inverse vertical velocity at horizontal object border
            if ( ! object[IX(i, j-1)]) x[IX(i, j)] =  -x[IX(i, j-1)];
            if ( ! object[IX(i, j+1)]) x[IX(i, j)] =  -x[IX(i, j+1)];
          } 
          else if (b == 0 ) {
 
        int count = 0;
        float tmp = 0.0f;
        x[IX(i, j)] = 0;
        if ( ! object[IX(i-1, j)]) { tmp += x[IX(i-1, j)]; count++; }
        if ( ! object[IX(i+1, j)]) { tmp += x[IX(i+1, j)]; count++; }
        if ( ! object[IX(i, j-1)]) { tmp += x[IX(i, j-1)]; count++; }
        if ( ! object[IX(i, j+1)]) { tmp += x[IX(i, j+1)]; count++; }
        if( count == 0){
          x[IX(i, j)] = 0; 
        } else {
             x[IX(i, j)] = tmp/count; 
        }
      
          }
/*       x[IX(i,j)]  = x[IX(i-1,j)];
        x[IX(i,j)] -= x[IX(i,j-1)];
        x[IX(i,j)] += x[IX(i+1,j)]; 
        x[IX(i,j)] -= x[IX(i+1,j+1)];
        
        x[IX(i,j)] *= 0.25;*/
      }
    }
  }
    
    
    
  for(int i=0; i<=N; i++){
/*float temp = x[IX(0 ,i)];
     x[IX(0 ,i)] = x[IX(N+1,i)];//(b==1 ? -x[IX(1,i)] : x[IX(1,i)]);
    x[IX(N+1,i)] = temp;        //(b==1 ? -x[IX(N,i)] : x[IX(N,i)]);
    temp = x[IX(i,0  )];         //(b==2 ? -x[IX(i,1)] : x[IX(i,1)]);
    x[IX(i,0  )] = x[IX(i,N+1)];//(b==2 ? -x[IX(i,N)] : x[IX(i,N)]);
    x[IX(i,N+1)] = temp;*/
    
    x[IX(0 ,i)] = 0;
    x[IX(N+1,i)] = x[IX(N,i)];
    x[IX(i,0  )] = x[IX(i,1  )];
    x[IX(i,N+1)] = x[IX(i,N)];
    
    
    
  }
  x[IX(0  ,0  )] = 0.5f*(x[IX(1,0  )]+x[IX(0  ,1)]);
  x[IX(0  ,N+1)] = 0.5f*(x[IX(1,N+1)]+x[IX(0  ,N)]);
  x[IX(N+1,0  )] = 0.5f*(x[IX(N,0  )]+x[IX(N+1,1)]);
  x[IX(N+1,N+1)] = 0.5f*(x[IX(N,N+1)]+x[IX(N+1,N)]);
}

void lin_solve(int N, int b, float[] x, float[] x0, float a, float c){
  for(int k=0;k<20;k++){
    for(int i=1;i<=N;i++){
      for(int j=1;j<=N;j++){
        x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)]+x[IX(i+1,j)]
                                      +x[IX(i,j-1)]+x[IX(i,j+1)]))/c;
      }
    }
    set_bnd( N, b, x);
  }
}

void diffuse( int N, int b, float[] x, float[] x0, float diff, float dt){
  float a=dt*diff*N*N;
  lin_solve( N, b, x, x0, a, (1+4*a));
}

void advect( int N, int b, float[] d, float[] d0,float[] u, float[] v, float dt){
  int i0,j0,i1,j1;
  float x,y,s0,t0,s1,t1,dt0;
  
  dt0 = dt*N;
  for(int i=1;i<=N;i++){
    for(int j=1;j<=N;j++){
      x = i-dt0*u[IX(i,j)]; y = j-dt0*v[IX(i,j)];
      if (x<0.5f){ x=0.5f;} if(x>N+0.5f){x=N+0.5f;} i0=(int)x; i1=i0+1;
      if (y<0.5f){ y=0.5f;} if(y>N+0.5f){y=N+0.5f;} j0=(int)y; j1=j0+1;
      s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
      d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
                   s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
    }
  }
  set_bnd( N, b, d);
}

void project( int N, float[] u, float[] v, float[] p, float[] div){
  for(int i=1;i<=N;i++){
    for(int j=1;j<=N;j++){
      div[IX(i,j)] = -0.5f*(u[IX(i+1,j)]-u[IX(i-1,j)]
                           +v[IX(i,j+1)]-v[IX(i,j-1)])/N;
      p[IX(i,j)] = 0;
    }
  }
  set_bnd(N, 0, div); set_bnd( N, 0, p);
  
  lin_solve( N, 0, p, div, 1, 4);
  for(int i=1;i<=N;i++){
    for(int j=1;j<=N;j++){
      u[IX(i,j)] -= 0.5f*N*(p[IX(i+1,j)]-p[IX(i-1,j)]);
      v[IX(i,j)] -= 0.5f*N*(p[IX(i,j+1)]-p[IX(i,j-1)]);
    }
  }
  set_bnd( N, 1, u); set_bnd( N, 2, v);
}

void dens_step( int N, float[] x, float[] x0, float[] u, float[] v, 
float diff, float dt){
  add_source ( N, x, x0, dt);
//  SWAP(x0,x); 
  float[] temp = x0; x0 = x; x = temp;
  diffuse( N, 0, x, x0, diff, dt);
//  SWAP(x0,x);
  temp = x0; x0 = x; x = temp;
  advect( N, 0, x, x0, u, v, dt);
}

void vel_step( int N, float[] u, float[] v, float[] u0, float[] v0,
float visc, float dt){
  add_source( N, u, u0, dt); add_source( N, v, v0, dt);
  SWAP(u0, u); 
//  float[] temp = u0; u0 = u; u = temp;
  diffuse ( N, 1, u, u0, visc, dt);
  SWAP(v0, v); 
//  temp = v0; v0 = v; v = temp;
  diffuse ( N, 2, v, v0, visc, dt);
  project ( N, u, v, u0, v0);
  SWAP(u0, u); SWAP(v0, v); 
//  temp = u0; u0 = u; u = temp;temp = v0; v0 = v; v = temp;
  advect( N, 1, u, u0, u0, v0, dt); advect( N, 2, v, v0, u0, v0, dt);
  project( N, u, v, u0, v0);
}


      

