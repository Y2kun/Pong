# frozen_string_literal: true

# Vector
class V
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def self.[](x, y)
    new(x, y)
  end

  def +(other)
    V[x + other.x, y + other.y]
  end

  def -(other)
    V[x - other.x, y - other.y]
  end

  def *(other)
    case other
    when V
      V[x * other.x, y * other.y]
    when Float, Integer
      V[x * other, y * other]
    else
      raise "#{other.class} is not allowed"
    end
  end

  def /(other)
    case other
    when V
      V[x / other.x, y / other.y]
    when Float, Integer
      V[x / other, y / other]
    else
      raise "#{other.class} is not allowed"
    end
  end

  def normalize
    length = Math.sqrt((x**2) + (y**2))
    normalized_x = x / length
    normalized_y = y / length
    V[normalized_x, normalized_y]
  end

  def clamp(f, low, high)
    f.clamp(low, high)
  end

  def inspect
    "(#{x} #{y})"
  end

  def angle_to(other)
    pos = other - self
    angle = Math.atan2(pos.y, pos.x) * (180.0 / Math::PI)
    angle.negative? ? angle + 360 : angle
  end

  def length
    Math.sqrt((x**2) + (y**2))
  end

  def rotate_around(v, degrees)
    rad = 180 / Math::PI
    c = Math.cos(degrees / rad)
    s = Math.sin(degrees / rad)
    v + V[((x - v.x) * c) - ((y - v.y) * s), ((x - v.x) * s) + ((y - v.y) * c)]
  end

  def eql?(other)
    other.class == V && other.x == x && other.y == y
  end
end
