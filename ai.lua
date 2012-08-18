--[[Interspace AI routines
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


ai = {}

--base AI for flying ship, could be used for player autopilot
function ai:newPilot(ship)
  self = {}
  self.ship = ship
  self.target = {}
  --Initial target is object start position. Later if target is in range of position then next sequence is triggered.
  self.target.x = self.ship.body:getX()
  self.target.y = self.ship.body:getY()
  self.update = function (dt) ai.roam(self) end
  return self
end

function ai.roam(current)
-- When in range of target area, pic new one at random.
  if ((current.target.x >= current.ship.body:getX()-100) and (current.target.x < current.ship.body:getX()+100)) and ((current.target.y >= current.ship.body:getY()-100) and (current.target.y < current.ship.body:getY()+100)) then
    current.target.x = math.random(100, worldloop - 100)
    current.target.y = math.random(100, worldloop - 100)
    print(current.target.x, current.target.y)
  end
  
  ai.moveto(current.ship, current.target)
  
end

function ai.moveto(ship, target)

  local vector1 = vector(ship.body:getX(),ship.body:getY())
  local vector2 =  vector(target.x,target.y)
  local distance = vector2 - vector1
  local force = 1
  local normforce = force*distance
  local velx, vely = ship.body:getLinearVelocity()
  local vel = math.sqrt(velx^2 + vely^2)
  
  if ((distance:len() > 10) and (vel < 500)) then
    ship.body:setLinearDamping(0) --handbrake off
    ship.body:applyForce(normforce.x,normforce.y)
  elseif ((distance:len() > 10) and (vel > 500)) then
    ship.body:setLinearDamping(1)
    --ship.body:applyForce(-normforce.x,-normforce.y) 
  elseif ((distance:len() <= 100)) then
    ship.body:setLinearDamping(2) --handbrake on
  end

end

