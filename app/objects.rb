module Themed
    def primary(args)
        THEME.fetch(args.state.theme).fetch(:primary)
    end

    def secondary(args)
        THEME.fetch(args.state.theme).fetch(:secondary)
    end
end

class Paddle
    include Themed
    attr_accessor :width, :heigth, :pos, :velocity, :speed, :score
    def initialize(args)
        @width = 15
        @heigth = 150
        @pos = V[0, args.grid.h * 0.5 - heigth * 0.5]
        @velocity = V[0, 0]
        @speed = args.state.p1_and_p2_speed
        @score = 0
    end

    def update(args)
        @pos += @velocity * @speed
        @velocity *= 0.8 # "Air Resistance"
        @velocity = V[0, 0] if @velocity.length < 0.1 # better number
        #Paddle Movement limiter
        @pos.y = 0 if @pos.y < 0
        max_h = args.grid.h - @heigth
        @pos.y = max_h if @pos.y > max_h
    end

    def draw(args)
        args.outputs.solids << primary(args).merge(x: @pos.x, y: @pos.y, w: @width, h: @heigth)
    end

    def hitbox
        {x: @pos.x, y: @pos.y, w: @width, h: @heigth}
    end
end

class Player1 < Paddle
    def update(args)
        key = args.inputs.keyboard.key_held
        if key.w
            @velocity += V[0, 1]
        elsif key.s
            @velocity += V[0, -1]
        end
        super(args)
    end

    def to_s
        "Player 1"
    end
end

class Player2 < Paddle
    def initialize(args)
        super
        @pos = V[args.grid.w - @width, args.grid.h * 0.5 - @heigth * 0.5]
    end

    def update(args)
        key = args.inputs.keyboard.key_held
        if key.up
            @velocity += V[0, 1]
        elsif key.down
            @velocity += V[0, -1]
        end
        super(args)
    end

    def to_s
        "Player 2"
    end
end

class Ai1 < Paddle
    def initialize(args)
        super
        @speed = args.state.ai1_and_ai2_speed
        @tolerance = 20
    end

    def update(args)
        ball = args.state.ball
        y_center = @pos.y + heigth * 0.5
        y_ball_center = ball.pos.y + ball.heigth * 0.5
        target = V[0, y_ball_center]
        args.outputs.primitives << {primitive_marker: :solid ,x: @pos.x, y: target.y, w: @width, h: 5, r: 75, g: 75, b: 75} if DEBUG
        unless y_center >= y_ball_center - @tolerance && y_center <= y_ball_center + @tolerance
            @velocity += (target - V[0, y_center]).normalize
        end
        super(args)
    end

    def draw(args)
        y_center = @pos.y + heigth * 0.5
        args.outputs.primitives << {primitive_marker: :solid ,x: @pos.x, y: y_center - @tolerance, w: @width, h: @tolerance * 2, r: 50, g: 50, b: 50} if DEBUG
        super(args)
    end

    def to_s
        "Ai 1"
    end
end

class Ai2 < Paddle
    def initialize(args)
        super
        @pos = V[args.grid.w - width, args.grid.h * 0.5 - heigth * 0.5]
        @speed = args.state.ai1_and_ai2_speed
        @tolerance = 20
    end

    def update(args)
        ball = args.state.ball
        y_center = @pos.y + heigth * 0.5
        y_ball_center = ball.pos.y + ball.heigth * 0.5
        target = V[0, y_ball_center]
        args.outputs.primitives << {primitive_marker: :solid ,x: @pos.x, y: target.y, w: @width, h: 5, r: 75, g: 75, b: 75} if DEBUG
        unless y_center >= y_ball_center - @tolerance && y_center <= y_ball_center + @tolerance
            @velocity += (target - V[0, y_center]).normalize
        end
        super(args)
    end

    def draw(args)
        y_center = @pos.y + heigth * 0.5
        args.outputs.primitives << {primitive_marker: :solid ,x: @pos.x, y: y_center - @tolerance, w: @width, h: @tolerance * 2, r: 50, g: 50, b: 50} if DEBUG
        super(args)
    end

    def to_s
        "Ai 2"
    end
end

class Ball
    attr_accessor :width, :heigth, :left, :right, :tone, :pos, :velocity, :speed
    def initialize(args, left, right)
        @width = 25
        @heigth = 25
        @left = left
        @right = right
        @pos = V[args.grid.w * 0.5 - @width * 0.5, args.grid.h * 0.5 - @heigth * 0.5]
        @velocity = V[[5, -5].sample, [1, -1].sample]
        @speed = 2
    end

    def update(args)
        @pos += @velocity * @speed
        @velocity = V[0, 0] if velocity.length < 0.01
        collision(args)
    end

    def draw(args)
        if args.state.theme == :dark
            args.outputs.solids << {x: @pos.x, y: @pos.y, w: @width, h: @heigth, r: 200, g: 200, b: 200}
        else
            args.outputs.solids << {x: @pos.x, y: @pos.y, w: @width, h: @heigth, r: 55, g: 55, b: 55}
        end
    end

    def hitbox
        {x: @pos.x, y: @pos.y, w: @width, h: @heigth}
    end

    def collision(args)
        #Walls
        if pos.y < 0
            @velocity = V[@velocity.x, @velocity.y.abs()]
            hit(args)
        elsif pos.y > args.grid.h - @heigth
            @velocity = V[@velocity.x, -(@velocity.y.abs())]
            hit(args)
        end

        #Paddels
        if @left.hitbox && hitbox.intersect_rect?(@left.hitbox)
            @velocity = V[-@velocity.x, @left.velocity.y]
            hit(args)
        elsif @right.hitbox && hitbox.intersect_rect?(@right.hitbox)
            @velocity = V[-@velocity.x, @right.velocity.y]
            hit(args)
        end

        #Goal
        if @pos.x < 0
            @right.score += 1
            reset(args)
        elsif @pos.x > args.grid.w - @width
            @left.score += 1
            reset(args)
        end
    end

    def reset(args)
        #left
        @left.pos = V[0, args.grid.h * 0.5 - @left.heigth * 0.5]
        @left.velocity = V[0, 0]
        #right
        @right.pos = V[args.grid.w - @right.width, args.grid.h * 0.5 - @right.heigth * 0.5]
        @right.velocity = V[0, 0]

        #self
        @pos = V[args.grid.w * 0.5 - @width * 0.5, args.grid.h * 0.5 - @heigth * 0.5]
        @velocity = V[[5, -5].sample, [1, -1].sample]
        args.state.countdown = args.state.rounddelay
        args.state.last_set_time = Time.new()
    end

    def hit(args)
        args.gtk.queue_sound "data/sound/ball-hit.mp3" if args.state.sound
    end
end