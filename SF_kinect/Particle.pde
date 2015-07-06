
class Particle {
  
  Body body;
  float r;
  
  color col;
  
  Particle(float x, float y, float _r, boolean fixed){
    r = _r;
    
    BodyDef bd = new BodyDef();
    if (fixed) bd.type = BodyType.STATIC;
    else bd.type = BodyType.DYNAMIC;
    
    bd.position = box2d.coordPixelsToWorld(x,y);
    body = box2d.world.createBody(bd);
    
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.00001;
    
    body.createFixture(fd);
    
    col = color(175);
  }
  
  void killBody(){
    box2d.destroyBody(body);
  }
  
  boolean done(){
    
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if(pos.y > height+r*2){
      killBody();
      return true;
    }
    return false;
  }
  
  void applyForce(Vec2 force) {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }
  
  void display(){
    
    Vec2 pos = box2d.getBodyPixelCoord(body);
    
    fill(col);
    noStroke();
    ellipse(pos.x,pos.y,r*2,r*2);
  }
  
}
