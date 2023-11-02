require "app/v.rb"

#The Config
ENABLE_FULLSCREEN = true
ENABLE_SOUND = true
ENABLE_2PLAYERMODE = false
SLOWMOTION = false # Halves the Game speed

#Values
WIN_THRESSHOLD = 10 #How many Points are required for Victory
PLAYER_SPEED   = 4
ENEMY_SPEED    = 3  #The Speed of the Ai

#Should not be changed
SCREEN_HEIGHT = 720
SCREEN_WIDTH = 1280

#Possible Changes

#Timer before the next round
#Ingame Config

def tick args
    args.gtk.request_quit if args.inputs.keyboard.key_held.escape
    args.gtk.reset if args.inputs.keyboard.key_held.control && args.inputs.keyboard.key_held.r
    args.gtk.set_window_fullscreen ENABLE_FULLSCREEN
    args.outputs.background_color = [20, 20, 20]
    args.gtk.slowmo! 2 if SLOWMOTION
    player = args.state.player ||= Player.new()
    if ENABLE_2PLAYERMODE
        player2 = args.state.player2 ||= Player2.new()
    else
        enemy = args.state.enemy ||= Enemy.new()
    end
    ball = args.state.ball ||= Ball.new()

    #Wins
    if args.state.player.score >= WIN_THRESSHOLD
        args.outputs.primitives << {primitive_marker: :solid, x: 0, y: 0,
                                 w: SCREEN_WIDTH, h: SCREEN_HEIGHT, r: 0, b: 0, g: 0}
        args.outputs.labels << {x: SCREEN_WIDTH * 0.5 - 100, y: SCREEN_HEIGHT * 0.5 + 55, text: "Victory for Player 1", r: 255, b: 255, g: 255}
    elsif ENABLE_2PLAYERMODE && args.state.player2.score >= WIN_THRESSHOLD
        args.outputs.primitives << {primitive_marker: :solid, x: 0, y: 0,
                                 w: SCREEN_WIDTH, h: SCREEN_HEIGHT, r: 0, b: 0, g: 0}
        args.outputs.labels << {x: SCREEN_WIDTH * 0.5 - 100, y: SCREEN_HEIGHT * 0.5 + 55, text: "Victory for Player 2", r: 255, b: 255, g: 255}
    elsif !ENABLE_2PLAYERMODE && args.state.enemy.score >= WIN_THRESSHOLD
        args.outputs.primitives << {primitive_marker: :solid, x: 0, y: 0,
                                 w: SCREEN_WIDTH, h: SCREEN_HEIGHT, r: 0, b: 0, g: 0}
        args.outputs.labels << {x: SCREEN_WIDTH * 0.5 - 100, y: SCREEN_HEIGHT * 0.5 + 55, text: "Victory for the Enemy", r: 255, b: 255, g: 255}
    else
        #If no one wins
        player.update(args)
        player.draw(args)
        if ENABLE_2PLAYERMODE
            player2.update(args)
            player2.draw(args)
        else
            enemy.update(args)
            enemy.draw(args)
        end
        ball.update(args)
        ball.draw(args)
    end

    #text
    args.outputs.labels << {x: SCREEN_WIDTH * 0.5 - 100 * 0.5, y: SCREEN_HEIGHT - 30, text: "p1 #{player.score}", r: 255, g: 255, b: 255}
    if ENABLE_2PLAYERMODE
        args.outputs.labels << {x: SCREEN_WIDTH * 0.5 + 50  * 0.5, y: SCREEN_HEIGHT - 30, text: "p2 #{player2.score}", r: 255, g: 255, b: 255}
    else
        args.outputs.labels << {x: SCREEN_WIDTH * 0.5 + 50  * 0.5, y: SCREEN_HEIGHT - 30, text: "e  #{enemy.score}", r: 255, g: 255, b: 255}
    end
end

class Paddle
    attr_accessor :width, :heigth, :tone, :pos, :velocity, :speed, :score
    def initialize
        @width = 15
        @heigth = 150
        @tone = 255
        @pos = V[0, SCREEN_HEIGHT * 0.5 - heigth * 0.5]
        @velocity = V[0, 0]
        @speed = PLAYER_SPEED
        @score = 0
    end

    def update(args)
        @pos += velocity * speed
        @velocity *= 0.8 # "Air Resistance"
        @velocity = V[0, 0] if velocity.length < 0.1 # better number
        #Paddle Movement limiter
        @pos.y = 0 if pos.y < 0
        @pos.y = SCREEN_HEIGHT - heigth if pos.y > SCREEN_HEIGHT - heigth
    end

    def draw(args)
        args.outputs.solids << {x: pos.x, y: pos.y, w: width, h: heigth, r: tone, g: tone, b: tone}
    end

    def hitbox
        {x: pos.x, y: pos.y, w: width, h: heigth}
    end
end

class Player < Paddle
    def initialize
        super
    end

    def update(args)
        if args.inputs.up
            @velocity += V[0, 1]
        elsif args.inputs.down
            @velocity += V[0, -1]
        end
        super(args)
    end
end

class Player2 < Paddle
    def initialize
        super
        @pos = V[SCREEN_WIDTH - width, SCREEN_HEIGHT * 0.5 - heigth * 0.5]
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
end

class Enemy < Paddle
    def initialize
        super
        @pos = V[SCREEN_WIDTH - width, SCREEN_HEIGHT * 0.5 - heigth * 0.5]
        @speed = ENEMY_SPEED
    end

    def update(args)
        target = V[0, args.state.ball.pos.y - heigth / 2]
        @velocity = (target - V[0, @pos.y]).normalize
        super(args)
    end
end

class Ball
    attr_accessor :width, :heigth, :tone, :pos, :velocity, :speed
    def initialize
        @width = 25
        @heigth = 25
        @tone = 200
        @pos = V[SCREEN_WIDTH * 0.5 - width * 0.5, SCREEN_HEIGHT * 0.5 - heigth * 0.5]
        @velocity = V[[10, -10].sample, 0]
        @speed = 2
    end

    def update(args)
        @pos += velocity * speed
        #@velocity *= 0.95
        @velocity = V[0, 0] if velocity.length < 0.01
        collision(args)
    end

    def draw(args)
        args.outputs.solids << {x: pos.x, y: pos.y, w: width, h: heigth, r: tone, g: tone, b: tone}
    end

    def hitbox
        {x: pos.x, y: pos.y, w: width, h: heigth}
    end

    def collision(args)
        #Walls
        if pos.y < 0
            @velocity = V[@velocity.x, -velocity.y]
            hit(args)
        elsif pos.y > SCREEN_HEIGHT - @heigth
            @velocity = V[@velocity.x, -velocity.y]
            hit(args)
        end

        #Paddels
        if hitbox.intersect_rect?(args.state.player.hitbox)
            @velocity = V[-@velocity.x, args.state.player.velocity.y]
            hit(args)
        elsif ENABLE_2PLAYERMODE && hitbox.intersect_rect?(args.state.player2.hitbox)
            @velocity = V[-@velocity.x, args.state.player2.velocity.y]
            hit(args)
        elsif !ENABLE_2PLAYERMODE && hitbox.intersect_rect?(args.state.enemy.hitbox)
            @velocity = V[-@velocity.x, args.state.enemy.velocity.y]
            hit(args)
        end

        #Goal
        if @pos.x < 0
            if ENABLE_2PLAYERMODE
                args.state.player2.score += 1
            else
                args.state.enemy.score += 1
            end
            reset(args)
        elsif @pos.x > SCREEN_WIDTH - @width
            args.state.player.score += 1
            reset(args)
        end
    end

    def reset(args)
        args.state.player.pos = V[0, SCREEN_HEIGHT * 0.5 - args.state.player.heigth * 0.5]
        args.state.player.velocity = V[0, 0]
        if ENABLE_2PLAYERMODE
            args.state.player2.pos = V[SCREEN_WIDTH - args.state.player2.width, SCREEN_HEIGHT * 0.5 - args.state.player2.heigth * 0.5]
            args.state.player2.velocity = V[0, 0]
        else
            args.state.enemy.pos = V[SCREEN_WIDTH - args.state.enemy.width, SCREEN_HEIGHT * 0.5 - args.state.enemy.heigth * 0.5]
            args.state.enemy.velocity = V[0, 0]
        end
        @pos = V[SCREEN_WIDTH * 0.5 - width * 0.5, SCREEN_HEIGHT * 0.5 - heigth * 0.5]
        @velocity = V[[10, -10].sample, 0]
    end

    def hit(args)
        args.gtk.queue_sound "data/sound/ball-hit.mp3" if ENABLE_SOUND
    end
end