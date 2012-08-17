--[[Interspace top-down space shooter game for Love2D
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

function love.load()
  --Get HUMP from http://vrld.github.com/hump/
  vector = require("hump.vector")
  camera = require("hump.camera")
  require("obj")
  --require("ai")
  
  time = 0
  
  --load sounds
  thrustsound = love.audio.newSource("sfx/thrust.wav", "static")
  thrustsound:setLooping(True)
  
  pewsound = love.audio.newSource("sfx/pew.wav", "static")
  pewsound:setLooping(True)
  
  -- Create physics world. Physics tutorial on Love2d wiki is good place to start understanding this. https://love2d.org/wiki/Tutorial:Physics and https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks
  love.physics.setMeter(64)
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
  
  --size of world until wrap around
  worldloop = 5000
  
 
  --Create Objects
  objects = {}
  objects.ships = {}
  
  --Player TODO Custom Shape
  objects.ships.player = obj:newShip(100,100)
  
  --ai ship
  enemy = {}
  --enemy.fighter = ai:newEnemyAI(3000,3000)
  
  --Dummy ship.
  --objects.ships.dummy = obj:newShip(200,200)
  
  objects.stars = {}
  --Sun
  --objects.stars.sun = obj:newStar()
  
  objects.asteroids = {}
  --Test asteroids
  for i = 0, 30, 1 do
  objects.asteroids[i] = obj:newAsteroid(math.random()*worldloop,math.random()*worldloop,1)
  end

  -- Bullets table, for bullet objects created by player
  objects.bullets = {}
  
  --Graphics setup
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setMode(1024, 768, false, true, 0)
  
  cam = camera(100,100, 1, 0)

end

function love.update(dt)
  world:update(dt) --this puts the world into motion (Physics tutorial)
  time = time + dt
  
  --remove dead objects before called
  for a,b in pairs(objects) do
    for i,v in pairs(b) do
      if v.isdead then print(time .. " " .. a .. " " .. i .. " is dead") b[i] = nil end
    end
  end
  
  --loop world at edges
  for a,b in pairs(objects) do
    for i,v in pairs(b) do
      if v.body:getX() > worldloop then
	v.body:setX(v.body:getX() - worldloop)
      end
      if v.body:getY() > worldloop then
	v.body:setY(v.body:getY() - worldloop)
      end
      if v.body:getX() < 0 then
	v.body:setX(v.body:getX() + worldloop)
      end
      if v.body:getY() < 0 then
	v.body:setY(v.body:getY() + worldloop)
      end
    end    
  end
  
  --TODO Zooming out when fast (cam.zoom)
  
  --player velocity (for debug)
  velx, vely = objects.ships.player.body:getLinearVelocity()
  vel = math.sqrt(velx^2 + vely^2)
  
  --Centre camera on player
  cam.x, cam.y = objects.ships.player.body:getX(),objects.ships.player.body:getY()
  
  --rotate camera with ship (TODO toggle option)
  --cam.rot = -objects.ships.player.body:getAngle() + math.rad(-90)
  
  --updates and applies gravity force on each object TODO Add to objectupdate()
  for a,b in pairs(objects) do
    for i,v in pairs(b) do
      v.update(dt)
      for d,c in pairs(objects) do
	for k,h in pairs(c) do
	  if (i ~= k) then
	    radgravity(v,h)
	  end
	end
      end
    end
  end

--enemy.fighter.update()

--Player control (TODO: Different method of turning for each type of ship? (torque, thrusters) TODO configurable keys TODO seperate table for player control like with AI.

  objects.ships.player.image = objects.ships.player.imageNormal
  if love.keyboard.isDown("left") then 
    objects.ships.player.left(dt)    
  elseif love.keyboard.isDown("right") then
    objects.ships.player.right(dt)
  elseif love.keyboard.isDown("up") then
    objects.ships.player.thrust()
    objects.ships.player.image = objects.ships.player.imageThrust
    love.audio.play(thrustsound)
    
  elseif love.keyboard.isDown(" ") then
    objects.ships.player.shoot()
    love.audio.play(pewsound)
  else
    love.audio.stop(thrustsound)
  end
  
end

--Radial Gravity, Method cribbed from http://www.vellios.com/2010/06/06/box2d-and-radial-gravity-code/ and blog comment by Joseph Le Brech
function radgravity(object1, object2)
  --body1 effected, body2 effector

  vector1 = vector(object1.body:getX(),object1.body:getY())
  vector2 =  vector(object2.body:getX(),object2.body:getY())
  distance = vector2 - vector1
  force = object2.force / distance:len2()
  normforce = force*distance
  
  --Added a distance limit to stop all objects falling into centre of level and forming gravity well (OF DOOM!)
  if (distance:len() < 1000) then
    object1.body:applyLinearImpulse(normforce.x,normforce.y,object1.body:getX(),object1.body:getY())  
  end
end



function love.draw()  

  cam:attach() --everything between this and cam:detach is redrawn in relation to the camera
  
  --Background, grid of green lines
    love.graphics.setColor(72, 160, 14) -- set the drawing color to green for lines
  for i = 0, worldloop, 100 do
    love.graphics.line( i, 0, i, worldloop)
    love.graphics.line( 0, i, worldloop, i)    
  end  
  
  love.graphics.setColor(255, 255, 255) --default white colour
  
  --Draw each object in each table
  for a,b in pairs(objects) do
  for i,v in pairs(b) do
    v.draw()
  end
  end
  
  cam:detach()
    
  --debug
  love.graphics.print( "coords " .. math.floor(objects.ships.player.body:getX()) .. "x" .. math.floor(objects.ships.player.body:getY()) .. " rot " .. objects.ships.player.body:getAngle() .. " speed " .. vel, 10, 10, 0, 1, 1)
  
  --HUDMap (TODO make seperate function)
  love.graphics.setColor(50,50,50,200)
  love.graphics.rectangle("fill", 900, 10, 100, 100)
  love.graphics.setColor(255,255,255)

  --draw each object in radar map
  for a,b in pairs(objects) do
  for i,v in pairs(b) do
    v.drawmap()
  end
  end
 
end

--Physics Callbacks: https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks
function beginContact(a, b, coll)
  --vx, vy = coll:getVelocity()
  --speed = math.sqrt(vx^2 + vy^2)
  object1 = a:getUserData()
  object2 = b:getUserData()
  if ((object1.isdead == true) or (object2.isdead == true)) then
    coll:setEnabled(false)
  else
  object1.integrity = object1.integrity - object2.hitdamage --* speed
  object2.integrity = object2.integrity - object1.hitdamage --* speed
  end
end

function endContact(a, b, coll)
    
end

function preSolve(a, b, coll)
    
end

function postSolve(a, b, coll)
    
end
