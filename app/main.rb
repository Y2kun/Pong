require "app/v.rb"
require "app/scene.rb"

#     Possible Changes
#Timer before the next round
#dark and light mode
#better paddle scripts
#Ingame Config

FONT = "data/fonts/TimeburnerBold.ttf"

def tick args
    initialize(args) if args.state.tick_count == 0
    window(args)
    
    args.state.scene.update(args)
    args.state.scene.draw(args)
end

def initialize(args)
    #config data
    args.state.fullscreen        = true
    args.state.sound             = true
    args.state.theme             = :dark
    args.state.two_p_mode        = false
    args.state.p1_and_p2_speed   = 4
    args.state.ai1_and_ai2_speed = 1.2
    args.state.win_threshhold    = 10 #How many Points are required for Victory
    #saves
    args.state.running           = true
    args.state.countdown         = 0
    args.state.rounddelay        = 3
    args.state.tone              = {}
    args.state.tone[:dark]       = [{r: 0, g: 0, b: 0}, {r: 255, g: 255, b: 255}]
    args.state.tone[:light]      = [{r: 255, g: 255, b: 255}, {r: 0, g: 0, b: 0}]
    args.state.scene             = MainMenu.new(args)
    args.state.last_set_time     = 0
end

def window(args)
    args.state.scene = MainMenu.new(args) if args.inputs.keyboard.key_held.escape
    args.gtk.set_window_fullscreen args.state.fullscreen
    if args.state.theme == :dark
        args.outputs.background_color = [20, 20, 20]
    else
        args.outputs.background_color = [235, 235, 235]
    end
end

class Paddle
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
        args.outputs.solids << args.state.tone[args.state.theme][1].merge(x: @pos.x, y: @pos.y, w: @width, h: @heigth)
    end

    def hitbox
        {x: pos.x, y: pos.y, w: width, h: heigth}
    end
end

class Player1 < Paddle
    def update(args)
        key = args.inputs.keyboard.key_held
        if key.w
            @velocity += V[0, 1]
            args.state.running = true
        elsif key.s
            @velocity += V[0, -1]
            args.state.running = true
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
        @pos = V[args.grid.w - width, args.grid.h * 0.5 - heigth * 0.5]
    end

    def update(args)
        key = args.inputs.keyboard.key_held
        if key.up
            @velocity += V[0, 1]
            args.state.running = true
        elsif key.down
            @velocity += V[0, -1]
            args.state.running = true
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
    end

    def update(args)
        target = V[0, args.state.ball.pos.y - heigth * 0.5]
        @velocity += (target - V[0, @pos.y]).normalize
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
    end

    def update(args)
        target = V[0, args.state.ball.pos.y - heigth * 0.5]
        @velocity += (target - V[0, @pos.y]).normalize
        super(args)
    end

    def to_s
        "Ai 2"
    end
end

class Ball
    attr_accessor :width, :heigth, :left, :right, :tone, :pos, :velocity, :speed
    def initialize(args, left, right, init_diagonal)
        @width = 25
        @heigth = 25
        @tone = 200
        @left = left
        @right = right
        @pos = V[args.grid.w * 0.5 - @width * 0.5, args.grid.h * 0.5 - @heigth * 0.5]
        @velocity = V[[10, -10].sample, 0] + init_diagonal
        @speed = 2
    end

    def update(args)
        @pos += @velocity * @speed
        @velocity = V[0, 0] if velocity.length < 0.01
        collision(args)
    end

    def draw(args)
        args.outputs.solids << {x: pos.x, y: pos.y, w: @width, h: @heigth, r: @tone, g: @tone, b: @tone}
        args.outputs.solids << {x: pos.x, y: pos.y, w: @width, h: @heigth, r: 55, g: 55, b: 55}
    end

    def hitbox
        {x: pos.x, y: pos.y, w: width, h: heigth}
    end

    def collision(args)
        #Walls
        if pos.y < 0
            @velocity = V[@velocity.x, -@velocity.y]
            hit(args)
        elsif pos.y > args.grid.h - @heigth
            @velocity = V[@velocity.x, -@velocity.y]
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
        @velocity = V[[10, -10].sample, 0]
        args.state.running = false
        args.state.countdown = args.state.rounddelay
        args.state.last_set_time = Time.new()
    end

    def hit(args)
        args.gtk.queue_sound "data/sound/ball-hit.mp3" if args.state.sound
    end
end