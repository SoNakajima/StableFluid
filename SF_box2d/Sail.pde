
class Sail {
  
  float totalLength;
  int numPoints;
  
  PVector[] POS = new PVector[11];
  
  Vec2[] defPos = new Vec2[11];
  Vec2[] prePos = new Vec2[11];
  
  ArrayList<Particle> particles;
  
  Sail(float l, int n){
    
    totalLength = l;
    numPoints = n;
    
    particles = new ArrayList();
    
    float len = totalLength / numPoints;
    
    
    
    for(int i=0; i < numPoints+1; i++){
      defPos[i] = new Vec2(i*len+100,200);
      prePos[i] = defPos[i];
      
      POS[i] = new PVector();
      
      Particle p = null;
      
      if(i == 0){ p = new Particle(i*len+100,200,4,true);}
      else if(i==1){  p = new Particle(i*len+100,170,4,false);}
      else if(i==2 || i==3){  p = new Particle(i*len+100,150,4,false);}
      else if(i==4){  p = new Particle(i*len+100,170,4,false);}
      else if(i==5){  p = new Particle(i*len+100,180,4,false);}
      else{ p = new Particle(i*len+100,200,4,false);}
      particles.add(p);
      
      Vec2 pos = box2d.getBodyPixelCoord(p.body);
      defPos[i] = pos;
      
      if(i > 0){
        DistanceJointDef djd = new DistanceJointDef();
        Particle previous = particles.get(i-1);
        
        djd.bodyA = previous.body;
        djd.bodyB = p.body;
        // Equibrium length
        djd.length = box2d.scalarPixelsToWorld(len);
        
        djd.frequencyHz = 0;
        djd.dampingRatio = 0;
        
        DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);
      }  
    }
   
  }
  
  void move(){
    for (int i=0; i<particles.size();i++){
      Particle p = particles.get(i);
      
      Vec2 pos = box2d.getBodyPixelCoord(p.body);
      
      POS[i].x = pos.x;
      POS[i].y = pos.y;
      
/*      float powX = (u[IX((int)(pos.x/width*N)-2,((int)(pos.y/height*N)))]
                   +u[IX((int)(pos.x/width*N)+2,((int)(pos.y/height*N)))])*50;
      float powY = (v[IX((int)(pos.x/width*N),((int)(pos.y/height*N))-2)]
                   +v[IX((int)(pos.x/width*N),((int)(pos.y/height*N))+2)])* -50; */
   
      float powX = 0;
      float powY = 0;
      
      ////// distance from default position
      float Ddist = sqrt((defPos[i].x-pos.x)*(defPos[i].x-pos.x)+(defPos[i].y-pos.y)*(defPos[i].y-pos.y));
      float ratio =adj*10;
      
      float RM = ratio * Ddist;
      if(defPos[i].x>pos.x)powX = RM;
      else powX = -RM;    
      if(defPos[i].y<pos.y)powY = RM;
      else powY = -RM;
     
      ///// distance from n-1 position
      float Pdist = sqrt((prePos[i].x-pos.x)*(prePos[i].x-pos.x)+(prePos[i].y-pos.y)*(prePos[i].y-pos.y));
      float damp = 5 * Pdist; 
      if(prePos[i].x>pos.x)powX += damp;
      else powX -= damp;     
      if(prePos[i].y<pos.y)powY += damp;
      else powY -= damp;     
                  
      if((i==particles.size()-1)||(i==particles.size()-2)) {
      powY -= trim;}
      Vec2 wind = new Vec2(powX,powY);
      p.applyForce(wind);
      
      prePos[i] = pos;
    }
  }
  
  
  
  void setObject(){
    for(int i=0; i<size; i++){
      object[i] = false;
    }
    
    for (int i=0; i<particles.size();i++){
      Particle p = particles.get(i);
      Vec2 pos = box2d.getBodyPixelCoord(p.body);
   
      object[IX((int)(pos.x/width*N), (int)(pos.y/height*N))] = true;
      object[IX((int)(pos.x/width*N), (int)(pos.y/height*N)-1)] = true;
      object[IX((int)(pos.x/width*N)-1, (int)(pos.y/height*N)-1)] = true;
      object[IX((int)(pos.x/width*N)+1, (int)(pos.y/height*N)-1)] = true;
      object[IX((int)(pos.x/width*N), (int)(pos.y/height*N)+1)] = true;
      object[IX((int)(pos.x/width*N)-1, (int)(pos.y/height*N)+1)] = true;
      object[IX((int)(pos.x/width*N)+1, (int)(pos.y/height*N)+1)] = true;      
      object[IX((int)(pos.x/width*N)-1, (int)(pos.y/height*N))] = true;
      object[IX((int)(pos.x/width*N)+1, (int)(pos.y/height*N))] = true;
      
      if(i != 0){
        Particle pp = particles.get(i-1);
        Vec2 ppos = box2d.getBodyPixelCoord(pp.body);
        
        float dist = sqrt((pos.x-ppos.x)*(pos.x-ppos.x)+(pos.y-ppos.y)*(pos.y-ppos.y));
   
        for(int j=1; j<pos.x-ppos.x;j++){
        float X = ppos.x+j*(pos.x-ppos.x)/dist;
        float Y = ppos.y+j*(pos.y-ppos.y)/dist;
        
        object[IX((int)(X/width*N), (int)(Y/height*N))] = true;
        object[IX((int)(X/width*N), (int)(Y/height*N)-1)] = true;
        object[IX((int)(X/width*N)-1, (int)(Y/height*N)-1)] = true;
        object[IX((int)(X/width*N)+1, (int)(Y/height*N)-1)] = true;
        object[IX((int)(X/width*N), (int)(Y/height*N)+1)] = true;
        object[IX((int)(X/width*N)-1, (int)(Y/height*N)+1)] = true;
        object[IX((int)(X/width*N)+1, (int)(Y/height*N)+1)] = true;      
        object[IX((int)(X/width*N)-1, (int)(Y/height*N))] = true;
        object[IX((int)(X/width*N)+1, (int)(Y/height*N))] = true;
        
        }      
      }
    }
  }
    
  void display(){
    for (Particle p: particles){
      p.display();
    }
  }
  
}
        
      
