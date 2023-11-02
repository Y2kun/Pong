class V
    attr_accessor :x, :y

    def initialize(x, y)
        @x = x
        @y = y
    end

    def self.[](x, y)
        new(x, y)
    end

    def +(vector2)
        V[x + vector2.x, y + vector2.y]
    end

    def -(vector2)
        V[x - vector2.x, y - vector2.y]
    end

    def *(vector2)
        case vector2
        when V
            V[x * vector2.x, y * vector2.y]
        when Float, Fixnum
            V[x * vector2, y * vector2]
        else
            raise "#{vector2.class} is not allowed"
        end
    end

    def /(vector2)
        case vector2
        when V
            V[x / vector2.x, y / vector2.y]
        when Float, Fixnum
            V[x / vector2, y / vector2]
        else
            raise "#{vector2.class} is not allowed"
        end
    end

    def normalize
        length = Math.sqrt(x**2 + y**2)
        normalized_x = x / length
        normalized_y = y / length
        V[normalized_x, normalized_y]
    end

    def clamp(f, low, high)
        if f > high
            high
        elsif f < low
            low
        else
            f
        end
    end


    def inspect
        "(#{x} #{y})"
    end

    def angle_to(other)
        pos = other - self
        angle = Math.atan2(pos.y, pos.x) * (180.0 / Math::PI)
        angle < 0 ? angle + 360 : angle
    end

    def length
        Math.sqrt(x ** 2 + y ** 2)
    end

    def rotate_around(v, degrees)
        f = 180 / Math::PI
        c, s = Math.cos(degrees / f), Math.sin(degrees / f)
        v + V[(x - v.x) * c - (y - v.y) * s, (x - v.x) * s + (y - v.y) * c]
    end
end
