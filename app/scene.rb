class MainMenu
    #attr_accessor 
    def initialize(args)
        @offset = [0] * 4
        @tone = {r: 255, g: 255, b: 255}
        @font = "data/fonts/TimeburnerBold.ttf"
    end

    def update(args)
        buttons = [{x: args.grid.w * 0.15 + @offset[0], y: args.grid.h * 0.75 - 35, w: 210 + @offset[0] * 12.5, h: 35},
                   {x: args.grid.w * 0.15 + @offset[1], y: args.grid.h * 0.7  - 29, w: 210 + @offset[1] * 13  , h: 29 - @offset[1] * 0.5},
                   {x: args.grid.w * 0.15 + @offset[2], y: args.grid.h * 0.65 - 35, w: 85  + @offset[2] * 5   , h: 35},
                   {x: args.grid.w * 0.15 + @offset[3], y: args.grid.h * 0.6  - 35, w: 110 + @offset[3] * 7   , h: 35}]
        #when hovering over a text option, should "highlight it"
        buttons.each_with_index do |button, index|
            if args.inputs.mouse.intersect_rect?(button)
                @offset[index] = 5
                args.state.scene = Game.new(args) if index == 0 && args.inputs.mouse.click
                args.gtk.notify! "This is not implimented yet" if index == 1 && args.inputs.mouse.click
                #args.state.scene = Options.new(args) if index == 2 && args.inputs.mouse.click
                args.gtk.notify! "This is not implimented yet" if index == 2 && args.inputs.mouse.click
                args.gtk.request_quit if index == 3 && args.inputs.mouse.click
            else
                @offset[index] = 0
            end
        end
    end

    def draw(args)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.1 , y: args.grid.h * 0.85, text: "Pong the Game"    , size_enum: 15, font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 + @offset[0], y: args.grid.h * 0.75, text: "Begin a new Game" , size_enum: 5 + @offset[0], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 + @offset[1], y: args.grid.h * 0.7 , text: "Continue the Game", size_enum: 5 + @offset[1], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 + @offset[2], y: args.grid.h * 0.65, text: "Options"          , size_enum: 5 + @offset[2], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 + @offset[3], y: args.grid.h * 0.6 , text: "Quit Game"        , size_enum: 5 + @offset[3], font: @font)
    end
end

class Options
    #attr_accessor 
    def initialize(args)
        #super
    end

    def update(args)
        #content
    end

    def draw(args)
        #content
    end
end

class Game
    attr_accessor :player, :ball
    attr_accessor :player2
    attr_accessor :enemy

    def initialize(args)
        @player = args.state.player = Player.new(args)
        #if args.state.two_player_mode
            @player2 = args.state.player2 = Player2.new(args)
        #else
            @enemy = args.state.enemy = Enemy.new(args)
        #end
        @ball = args.state.ball = Ball.new(args)
    end

    def update(args)
        if winning_player = winner(args)
            args.state.scene = Win.new(args, winning_player)
            return
        end
        @player.update(args)
        if args.state.two_player_mode
            @player2.update(args)
        else
            @enemy.update(args)
        end
        @ball.update(args) if !args.state.paused
    end

    def draw(args)
        @player.draw(args)
        args.outputs.labels << {x: args.grid.w * 0.4, y: args.grid.h - 30, text: "p1 #{@player.score}", size_enum: 2, r: 255, g: 255, b: 255}
        if args.state.two_player_mode
            @player2.draw(args)
            args.outputs.labels << {x: args.grid.w * 0.6, y: args.grid.h - 30, text: "p2 #{@player2.score}", size_enum: 2, r: 255, g: 255, b: 255}
        else
            @enemy.draw(args)
            args.outputs.labels << {x: args.grid.w * 0.6, y: args.grid.h - 30, text: "e  #{@enemy.score}", size_enum: 2, r: 255, g: 255, b: 255}
        end
        @ball.draw(args)
    end

    def winner(args)
        [player, player2, enemy].compact.find{|e| e.score >= args.state.win_threshhold }
    end
end

class Win
    attr_accessor :winning_player

    def initialize(args, winning_player)
        @winning_player = winning_player
    end

    def update(args)
        restart(args) if args.inputs.keyboard.key_held.enter

    end

    def draw(args)
        args.outputs.primitives << {primitive_marker: :solid, x: 0, y: 0,
                                    w: args.grid.w, h: args.grid.h, r: 0, b: 0, g: 0}
        args.outputs.labels << {x: args.grid.w * 0.35, y: args.grid.h * 0.5 + 55, text: text, size_enum: 4, r: 255, b: 255, g: 255}
    end

    def text
        "Victory for #{winning_player}: Score #{winning_player.score}"
    end

    def restart(args)
        args.state.scene = Game.new(args)
    end
end