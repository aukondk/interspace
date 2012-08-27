--[[Interspace object routines
    Copyright (C) 2012  Stephen Ward (Aukondk) aukondk.com bluedrava.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>--]]

obj = {}

--TODO Stop embedding custom functions in each object, try to call seperate ones when enough code is being replicated.

function obj:newShip(x,y)
  self = {}
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.body:setAngle(0)
  self.shape = love.physics.newRectangleShape(0, 0, 100/2, 100/2)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)
  self.force = 50
  self.imageNormal = love.graphics.newImage("gfx/ship.png")
  self.imageThrust = love.graphics.newImage("gfx/ship2.png")
  self.image = self.imageNormal 
  self.draw = function () love.graphics.draw(self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), 1/2, 1/2, 50, 50) love.graphics.print( self.integrity, self.body:getX(), self.body:getY()) end
  self.drawmap = function () love.graphics.draw(self.image, 900 + (self.body:getX()/(worldloop/100)), 10 + (self.body:getY()/(worldloop/100)), self.body:getAngle(), 1/10, 1/10, 50, 50) end
  self.thrustAmt = 100
  self.left = function (dt) self.body:applyTorque(-100000*dt) end
  self.right = function (dt) self.body:applyTorque(100000*dt) end
  self.thrust = function () self.body:applyForce(self.thrustAmt * math.cos(self.body:getAngle()), self.thrustAmt *  math.sin(self.body:getAngle())) end
  self.canshoot = 1
  self.shoot = function () if (self.canshoot >= 1) then weapon.laser(self) end end--table.insert(objects.bullets, obj:newBullet(self.body:getX() + (50 * math.cos(self.body:getAngle())), self.body:getY() + (50 * math.sin(self.body:getAngle())), self.body:getAngle())) self.canshoot = 0 end end
  self.integrity = 500
  self.hitdamage = 10
  self.isdead = false
  self.body:setLinearDamping(0.1)
  self.update = function (dt) if (self.canshoot < 1) then self.canshoot = self.canshoot + 4*dt end if self.integrity <= 0 then self.isdead = true end end
  return self
end

function obj:newUFO(x,y)
  self = obj:newShip(x,y)
  self.shape = love.physics.newCircleShape(25)
  self.imageNormal = love.graphics.newImage("gfx/ufo.png")
  self.image = self.imageNormal
  --self.shoot = function () if (self.canshoot >= 1) then table.insert(objects.bullets, obj:newBullet(self.body:getX() + (50 * math.cos(self.body:getAngle())), self.body:getY() + (50 * math.sin(self.body:getAngle())), self.body:getAngle())) self.canshoot = 0 end end
  return self
end

function obj:newBullet(x, y, a)
  self = {}
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newCircleShape(5)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)
  self.force = 25 --TODO Grav force for bullet?
  self.draw = function () love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius()) end
  self.drawmap = function () end
  self.body:applyLinearImpulse( 50 * math.cos(a), 50 *  math.sin(a) )
  self.integrity = 1
  self.hitdamage = 10
  self.isdead = false
  self.time = 1
  self.update = function (dt) self.time = self.time - 2*dt if self.time <= 0 then self.isdead = true end if self.integrity <= 0 then self.isdead = true end end
  return self
end

function obj:newAsteroid(x,y,s)
  self = {}
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.sizetype = s
  self.shape = love.physics.newCircleShape(50/s)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)
  self.force = 25/s
  self.draw = function () love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius()) love.graphics.print( self.integrity, self.body:getX(), self.body:getY() + 50) end
  self.drawmap = function () love.graphics.circle("fill", 900 + (self.body:getX()/(worldloop/100)), 10 + (self.body:getY()/(worldloop/100)), self.shape:getRadius()/(worldloop/100)) end
  self.integrity = 100
  self.hitdamage = 10  
  self.isdead = false
  self.update = function () if self.integrity <= 0 then self.isdead = true if (s < 3) then table.insert(objects.asteroids, obj:newAsteroid(self.body:getX()+1, self.body:getY()+1,self.sizetype+1)) table.insert(objects.asteroids, obj:newAsteroid(self.body:getX()-1, self.body:getY()-1,self.sizetype+1)) end end end
  return self
end

function obj:newStar()
  self = {}
  self.body = love.physics.newBody(world, 2500, 2500, "static")
  self.shape = love.physics.newCircleShape(200)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)
  self.force = 500
  self.draw = function () love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius()) end
  self.drawmap = function () love.graphics.circle("fill", 900 + (self.body:getX()/(worldloop/100)), 10 + (self.body:getY()/(worldloop/100)), self.shape:getRadius()/(worldloop/100)) end
  self.integrity = 10000
  self.hitdamage = 10000
  self.isdead = false
  self.update = function () if self.integrity <= 0 then self.isdead = true end end
  return self

end

function obj:newStation(x,y)
  self = {}
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newCircleShape(200)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)
  self.force = 100
  self.draw = function () love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius()) end
  self.drawmap = function () love.graphics.circle("fill", 900 + (self.body:getX()/(worldloop/100)), 10 + (self.body:getY()/(worldloop/100)), self.shape:getRadius()/(worldloop/100)) end
  self.integrity = 1000
  self.hitdamage = 100
  self.isdead = false
  self.update = function () obj.deflector(self) if self.integrity <= 0 then self.isdead = true end end
  return self

end

function obj.deflector(generator)
  for a,b in pairs(objects) do
    for i,v in pairs(b) do
      if (v ~= generator) then
      vector1 = vector(v.body:getX(),v.body:getY())
      vector2 =  vector(generator.body:getX(),generator.body:getY())
      distance = vector2 - vector1
      force = generator.force / distance:len2()
      normforce = force*distance
      if (distance:len() < 1000) then
	v.body:applyLinearImpulse(-normforce.x,-normforce.y)  
      end
      end
    end
  end
end