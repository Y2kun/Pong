require "app/v.rb"
require "app/scene.rb"

#                           Possible Changes
#Timer before the next round
#dark and light mode
#only ai playing #possibly the background for the main menu and options
#better paddle scripts
#Ingame Config

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
    args.state.two_player_mode   = false
    args.state.p1_and_p2_speed   = 4
    args.state.ai1_and_ai2_speed = 5
    args.state.win_threshhold    = 10 #How many Points are required for Victory
    #saves
    args.state.scene             = MainMenu.new(args)#MainMenu.new(args)
    args.state.paused            = true
    args.state.current_time      = Time.now()
end

def window(args)
    args.state.scene = MainMenu.new(args) if args.inputs.keyboard.key_held.escape
    args.gtk.set_window_fullscreen args.state.fullscreen
    args.outputs.background_color = [20, 20, 20]
end

class Paddle
    attr_accessor :width, :heigth, :tone, :pos, :velocity, :speed, :score
    def initialize(args)
        @width = 15
        @heigth = 150
        @tone = 255
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
        args.outputs.solids << {x: @pos.x, y: @pos.y, w: @width, h: @heigth, r: @tone, g: @tone, b: @tone}
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
            args.state.paused = false
        elsif key.s
            @velocity += V[0, -1]
            args.state.paused = false
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
            args.state.paused = false
        elsif key.down
            @velocity += V[0, -1]
            args.state.paused = false
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
        target = V[0, args.state.ball.pos.y - heigth / 2]
        @velocity = (target - V[0, @pos.y]).normalize
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
        target = V[0, args.state.ball.pos.y - heigth / 2]
        @velocity = (target - V[0, @pos.y]).normalize
        super(args)
    end

    def to_s
        "Ai 2"
    end
end

class Ball
    attr_accessor :width, :heigth, :tone, :pos, :velocity, :speed
    def initialize(args, init_diagonal)
        @width = 25
        @heigth = 25
        @tone = 200
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
        if args.state.player1.hitbox && hitbox.intersect_rect?(args.state.player1.hitbox)
            @velocity = V[-@velocity.x, args.state.player1.velocity.y]
            hit(args)
        elsif args.state.player2.hitbox && hitbox.intersect_rect?(args.state.player2.hitbox)
            @velocity = V[-@velocity.x, args.state.player2.velocity.y]
            hit(args)
        elsif args.state.ai1.hitbox && hitbox.intersect_rect?(args.state.ai1.hitbox)
            @velocity = V[-@velocity.x, args.state.ai2.velocity.y * 2]
            hit(args)
        elsif args.state.ai2.hitbox && hitbox.intersect_rect?(args.state.ai2.hitbox)
            @velocity = V[-@velocity.x, args.state.ai2.velocity.y * 2]
            hit(args)
        end

        #Goal
        if @pos.x < 0
            args.state.player2.score += 1 if args.state.player2.score
            args.state.ai2.score += 1 if args.state.ai2.score
            reset(args)
        elsif @pos.x > args.grid.w - @width
            args.state.player1.score += 1 if args.state.player1.score
            args.state.ai1.score += 1 if args.state.ai1.score
            reset(args)
        end
    end

    def reset(args)
        #left
        if args.state.player1.pos
            args.state.player1.pos = V[0, args.grid.h * 0.5 - args.state.player1.heigth * 0.5]
            args.state.player1.velocity = V[0, 0]
        elsif args.state.ai1.pos
            args.state.ai1.pos = V[0, args.grid.h * 0.5 - args.state.ai1.heigth * 0.5]
            args.state.ai1.velocity = V[0, 0]
        end
        #right
        if args.state.player2.pos
            args.state.player2.pos = V[args.grid.w - args.state.player2.width, args.grid.h * 0.5 - args.state.player2.heigth * 0.5]
            args.state.player2.velocity = V[0, 0]
        elsif args.state.ai2.pos
            args.state.ai2.pos = V[args.grid.w - args.state.ai2.width, args.grid.h * 0.5 - args.state.ai2.heigth * 0.5]
            args.state.ai2.velocity = V[0, 0]
        end

        #self
        @pos = V[args.grid.w * 0.5 - width * 0.5, args.grid.h * 0.5 - heigth * 0.5]
        @velocity = V[[10, -10].sample, 0]
        args.state.paused = true
    end

    def hit(args)
        args.gtk.queue_sound "data/sound/ball-hit.mp3" if args.state.sound
    end
end