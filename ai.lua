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

--TODO Need to rewrite this whole thing, needs to be passed an object table instead of creating new object.

ai = {}

function ai:newEnemyAI(x,y)
  self = {}
  self.pos.x = x
  self.pos.y = y
  objects.self = obj:newShip(x,y)
  self.target = nil
  self.update = function () self.pos.x = object.self.body:getX() self.pos.y = object.self.body:getY() ai.intent(self.target, self.pos) end
end

function ai.intent(target, pos)
  --check for enemy in detection range
  --enemy = objects.player
  --if enemy, 
  --ai.attack(enemy)
  
  --if not, 
  ai.scout(target, pos)
end

function ai.scout(target, pos)
  --check for existing target  
  if (target = nil) then
  --if not, pick point on map (search pattern?)
    target = ["x" = rand(0, worldloop), "y" = rand(0,worldloop)]
  end
  ai.move(target, pos)
  --move towards it
  --return target
end

function ai.move(target, pos)
    --body1 effected, body2 effector
  local vector1 = vector(pos.x, pos.y)
  local vector2 =  vector(target.x,target.y)
  local distance = vector2 - vector1
  local force = object2.force / distance:len2()
  local normforce = force*distance
  objects.self.body:applyForce(normforce.x,normforce.y) 
  --if facing target, thrust
  --if not, turn
  
end


function ai.attack(target)
  --if in range of target, turn towards it
  --if facing, fire
  --if not in range, move(target)
end
