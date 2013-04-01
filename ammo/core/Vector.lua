-- based on hump.vector
Vector = class("Vector")

function Vector:initialize(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Vector:unpack()
  return self.x, self.y
end

function Vector:set(x, y)
  if x then self.x = x end
  if y then self.y = y end
end

function Vector:normalize()
  local len = self:len()
  self.x, self.y = self.x / len, self.y / len
  return self
end

function Vector:normalized()
  return self / self:len()
end

function Vector:rotate(by)
  local c, s = math.cos(by), math.sin(by)
  self.x = c * self.x - s * self.y
  self.y = s * self.x + c * self.y
  return self
end

function Vector:rotated(by)
  return Vector(self.x, self.y):rotate(by)
end

function Vector:perpendicular()
  return Vector(-self.y, self.x)
end

function Vector:projectOn(v)
  return (self * v) * v / v:lenSq()
end

function Vector:cross(v)
  return self.x * v.y - self.y * v.x
end

function Vector:permul(v)
  return Vector(self.x * v.x, self.y * v.y)
end

function Vector:dist(v)
  return (v - self):len()
end

function Vector:lenSq()
  return self * self
end

function Vector:len()
  return math.sqrt(self * self)
end

function Vector:__tostring()
  return "(" .. self.x .. "," .. self.y ..")"
end

function Vector:__unm()
  return Vector(-self.x, -self.y)
end

function Vector:__add(v)
  return Vector(self.x + v.x, self.y + v.y)
end

function Vector:__sub(v)
  return Vector(self.x - v.x, self.y - v.y)
end

function Vector.__mul(a, b)
  if type(b) == "number" then
    return Vector(a.x * b, a.y * b)
  elseif type(a) == "number" then
    return Vector(b.x * a, b.y * a)
  else
    return a.x * b.x + a.y * b.y
  end
end

function Vector:__div(v)
  return Vector(self.x / v, self.y / v)
end

function Vector:__eq(v)
  return self.x == v.x and self.y == v.y
end

function Vector:__lt(v)
  return self.x < v.x or (self.x == v.x and self.y < v.y)
end

function Vector:__le(v)
  return self.x <= v.x and self.y <= v.y
end
