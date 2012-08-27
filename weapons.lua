weapon = {}

function weapon.laser(ship)
  table.insert (weapons.beams, weapon:newLaser(ship))
  --lastbeam = weapons.beams[table.getn(weapons.beams)]
  --world:rayCast( lastbeam.ray.startx, lastbeam.ray.starty, lastbeam.ray.endx, lastbeam.ray.endy, weapon.lasercallback )
end

--Maybe laser should be object table created by shooting and with own update() and draw()
function weapon:newLaser(ship)
  self = {}
  self.ray = {}
  
  
  self.ray.startx = ship.body:getX()
  self.ray.starty = ship.body:getY()
  self.ray.vec = vector(1,0):rotated(ship.body:getAngle())
  self.ray.endx, self.ray.endy = self.ray.vec:unpack()
  self.ray.endx = self.ray.startx +(self.ray.endx * 500)
  self.ray.endy = self.ray.starty +(self.ray.endy * 500)
  self.update = function (dt) self.duration = self.duration - dt end
  self.duration = 1
  self.draw = function () love.graphics.setLineWidth(3) love.graphics.setColor(255, 100, 100, self.duration * 255) love.graphics.line(self.ray.startx, self.ray.starty,self.ray.endx, self.ray.endy) end
  
  world:rayCast( self.ray.startx, self.ray.starty, self.ray.endx, self.ray.endy, weapon.lasercallback )
  love.audio.play(pewsound)
  --table.insert(beams, self.ray)
  --print(ray.startx, ray.starty, ray.endx, ray.endy)
  ship.canshoot=0
  
  return self
end

--similar to physics callbacks in main.lua. How to get hit coords back to draw laser?
function weapon.lasercallback(fixture, x, y, xn, yn, fraction)
  
  --use x and y for position of explosion, xn and yn for richochet?
  
  object = fixture:getUserData()
  object.integrity = object.integrity - 10
  lastbeam = weapons.beams[table.getn(weapons.beams)-1]
  if lastbeam then
    lastbeam.ray.endx = x
    lastbeam.ray.endy = y
  end
  
  return 0
end