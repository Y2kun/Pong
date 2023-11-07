class MainMenu
    attr_accessor :ai1, :ai2, :ball
    def initialize(args)
        @ai1 = args.state.ai1 = Ai1.new(args)
        @ai2 = args.state.ai2 = Ai2.new(args)
        @ball = args.state.ball = Ball.new(args, [V[5, 5], V[-5, -5], V[5, -5], V[-5, 5]].sample)
        @offset = [0] * 4
        @tone = {r: 255, g: 255, b: 255}
        @font = "data/fonts/TimeburnerBold.ttf"
    end

    def update(args)
        @ai1.update(args)
        @ai2.update(args)
        @ball.update(args)

        buttons = [{x: args.grid.w * 0.15 - @offset[0], y: args.grid.h * 0.75 - 35, w: 210 + @offset[0] * 12.5, h: 35},
                   {x: args.grid.w * 0.15 - @offset[1], y: args.grid.h * 0.7  - 29, w: 210 + @offset[1] * 13  , h: 29 - @offset[1] * 0.5},
                   {x: args.grid.w * 0.15 - @offset[2], y: args.grid.h * 0.65 - 35, w: 85  + @offset[2] * 5   , h: 35},
                   {x: args.grid.w * 0.15 - @offset[3], y: args.grid.h * 0.6  - 35, w: 110 + @offset[3] * 7   , h: 35}]
        #when hovering over a text option, should "highlight it"
        buttons.each_with_index do |button, index|
            #args.outputs.borders << @tone.merge(button) #for seeing the interactible area
            if args.inputs.mouse.intersect_rect?(button)
                @offset[index] = 5
                args.state.scene = Game.new(args) if index == 0 && args.inputs.mouse.click
                args.gtk.notify! "This is not implimented yet" if index == 1 && args.inputs.mouse.click
                args.state.scene = Options.new(args) if index == 2 && args.inputs.mouse.click
                #args.gtk.notify! "This is not implimented yet" if index == 2 && args.inputs.mouse.click
                args.gtk.request_quit if index == 3 && args.inputs.mouse.click
            else
                @offset[index] = 0
            end
        end
    end

    def draw(args)
        @ai1.draw(args)
        @ai2.draw(args)
        @ball.draw(args)

        args.outputs.labels << @tone.merge(x: args.grid.w * 0.1 , y: args.grid.h * 0.85, text: "Pong the Game"    , size_enum: 15, font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 - @offset[0], y: args.grid.h * 0.75, text: "Begin a new Game" , size_enum: 5 + @offset[0], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 - @offset[1], y: args.grid.h * 0.7 , text: "Continue the Game", size_enum: 5 + @offset[1], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 - @offset[2], y: args.grid.h * 0.65, text: "Options"          , size_enum: 5 + @offset[2], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.15 - @offset[3], y: args.grid.h * 0.6 , text: "Quit Game"        , size_enum: 5 + @offset[3], font: @font)
    end
end

class Options
    attr_accessor :ai1, :ai2, :ball
    def initialize(args)
        @ai1 = args.state.ai1 = Ai1.new(args)
        @ai2 = args.state.ai2 = Ai2.new(args)
        @ball = args.state.ball = Ball.new(args, [V[5, 5], V[-5, -5], V[5, -5], V[-5, 5]].sample)
        @offset = [0] * 6
        @tone = {r: 255, g: 255, b: 255}
        @font = "data/fonts/TimeburnerBold.ttf"
        @buttons = [{x: args.grid.w * 0.25, y: args.grid.h * 0.75 - 40, w: 50, h: 50},
                    {x: args.grid.w * 0.25, y: args.grid.h * 0.65 - 40, w: 50, h: 50},
                    {x: args.grid.w * 0.25, y: args.grid.h * 0.55 - 40, w: 50, h: 50},
                    {x: args.grid.w * 0.25, y: args.grid.h * 0.45 - 40, w: 50, h: 50},
                    {x: args.grid.w * 0.25, y: args.grid.h * 0.35 - 40, w: 50, h: 50},
                    {x: args.grid.w * 0.25, y: args.grid.h * 0.25 - 40, w: 50, h: 50}]
    end
    
    def update(args)
        @ai1.update(args)
        @ai2.update(args)
        @ball.update(args)

        higlight_box = [{x: args.grid.w * 0.3 - @offset[0] - 50, y: args.grid.h * 0.75 - 35, w: 110 + @offset[0] * 8   + 50, h: 35},
                        {x: args.grid.w * 0.3 - @offset[1] - 50, y: args.grid.h * 0.65 - 29, w: 70  + @offset[1] * 5   + 50, h: 30},
                        {x: args.grid.w * 0.3 - @offset[2] - 50, y: args.grid.h * 0.55 - 35, w: 88  + @offset[2] * 5.5 + 50, h: 35},
                        {x: args.grid.w * 0.3 - @offset[3] - 50, y: args.grid.h * 0.45 - 35, w: 165 + @offset[3] * 10  + 50, h: 35},
                        {x: args.grid.w * 0.3 - @offset[4] - 50, y: args.grid.h * 0.35 - 35, w: 160 + @offset[4] * 9   + 50, h: 35},
                        {x: args.grid.w * 0.3 - @offset[5] - 50, y: args.grid.h * 0.25 - 35, w: 110 + @offset[5] * 7   + 50, h: 35}]

        
        #when hovering over a text option, should "highlight it"
        higlight_box.each_with_index do |box, index|
            #args.outputs.borders << @tone.merge(box)
            if args.inputs.mouse.intersect_rect?(box)
                @offset[index] = 5
            else
                @offset[index] = 0
            end
        end

        @buttons.each_with_index do |button, index|
            if args.inputs.mouse.intersect_rect?(button)
                args.state.fullscreen      = !args.state.fullscreen      if index == 0 && args.inputs.mouse.click
                args.state.sound           = !args.state.sound           if index == 1 && args.inputs.mouse.click
                args.state.two_player_mode = !args.state.two_player_mode if index == 2 && args.inputs.mouse.click
                args.gtk.notify! "This is not implimented yet" if index == 3 && args.inputs.mouse.click
                args.gtk.notify! "This is not implimented yet" if index == 4 && args.inputs.mouse.click
                args.gtk.notify! "This is not implimented yet" if index == 5 && args.inputs.mouse.click
            end
        end
    end

    def draw(args)
        @ai1.draw(args)
        @ai2.draw(args)
        @ball.draw(args)
        #Text
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.45            , y: args.grid.h * 0.9 , text: "Options"       , size_enum: 15             , font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.3 - @offset[0], y: args.grid.h * 0.75, text: "Fullscreen"    , size_enum: 5  + @offset[0], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.3 - @offset[1], y: args.grid.h * 0.65, text: "Sound"         , size_enum: 5  + @offset[1], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.3 - @offset[2], y: args.grid.h * 0.55, text: "2 Player"      , size_enum: 5  + @offset[2], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.3 - @offset[3], y: args.grid.h * 0.45, text: "Score Required", size_enum: 5  + @offset[3], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.3 - @offset[4], y: args.grid.h * 0.35, text: "Player Speeds" , size_enum: 5  + @offset[4], font: @font)
        args.outputs.labels << @tone.merge(x: args.grid.w * 0.3 - @offset[5], y: args.grid.h * 0.25, text: "Ai Speeds"     , size_enum: 5  + @offset[5], font: @font)
        #Buttons
        @buttons.each_with_index do |button, index|
            args.outputs.borders << @tone.merge(button)
            args.outputs.solids  << @tone.merge({x: args.grid.w * 0.25 + 15 * 0.5, y: args.grid.h * 0.75 - 40 + 15 * 0.5, w: 35, h: 35}) if index == 0 && args.state.fullscreen      == true
            args.outputs.solids  << @tone.merge({x: args.grid.w * 0.25 + 15 * 0.5, y: args.grid.h * 0.65 - 40 + 15 * 0.5, w: 35, h: 35}) if index == 1 && args.state.sound           == true
            args.outputs.solids  << @tone.merge({x: args.grid.w * 0.25 + 15 * 0.5, y: args.grid.h * 0.55 - 40 + 15 * 0.5, w: 35, h: 35}) if index == 2 && args.state.two_player_mode == true
        end
        args.outputs.labels << {x: 50, y: 50, text: "Esc to return to Main Menu", r: 255, g: 255, b: 255, font: "data/fonts/TimeburnerBold.ttf"}
    end
end

class Game
    attr_accessor :player1, :player2, :ball, :ai2
    def initialize(args)
        @player1 = args.state.player1 = Player1.new(args)
        if args.state.two_player_mode
            @player2 = args.state.player2 = Player2.new(args)
            @ai2 = args.state.ai2 = nil
        else
            @ai2 = args.state.ai2 = Ai2.new(args)
            @player2 = args.state.player2 = nil
        end
        @ball = args.state.ball = Ball.new(args, V[0, 0])
    end

    def update(args)
        if winning_player = winner(args)
            args.state.scene = Win.new(args, winning_player)
            return
        end
        @player1.update(args)
        if @player2
            @player2.update(args)
        else
            @ai2.update(args)
        end
        @ball.update(args) if !args.state.paused
    end

    def draw(args)
        @player1.draw(args)
        args.outputs.labels << {x: args.grid.w * 0.4, y: args.grid.h - 30, text: "p1 #{@player1.score}", size_enum: 2, r: 255, g: 255, b: 255}
        if args.state.two_player_mode
            @player2.draw(args)
            args.outputs.labels << {x: args.grid.w * 0.6, y: args.grid.h - 30, text: "p2 #{@player2.score}", size_enum: 2, r: 255, g: 255, b: 255}
        else
            @ai2.draw(args)
            args.outputs.labels << {x: args.grid.w * 0.6, y: args.grid.h - 30, text: "e  #{@ai2.score}", size_enum: 2, r: 255, g: 255, b: 255}
        end
        @ball.draw(args)
        args.outputs.labels << {x: 50, y: 50, text: "Esc to return to Main Menu", r: 255, g: 255, b: 255, font: "data/fonts/TimeburnerBold.ttf"}
    end

    def winner(args)
        [player1, player2, ai2].compact.find{|e| e.score >= args.state.win_threshhold }
    end
end

class Win
    attr_accessor :winning_player

    def initialize(args, winning_player)
        @winning_player = winning_player
    end

    def update(args)
        restart(args) if args.inputs.keyboard.key_held.r
    end

    def draw(args)
        args.outputs.primitives << {primitive_marker: :solid, x: 0, y: 0, w: args.grid.w, h: args.grid.h, r: 0, b: 0, g: 0}
        args.outputs.labels << {x: args.grid.w * 0.4 , y: args.grid.h * 0.5 + 55, text: text, size_enum: 4, r: 255, b: 255, g: 255}
        args.outputs.labels << {x: 30, y: args.grid.h * 0.95, text: "Press Esc to return to Main Menu", r: 255, g: 255, b: 255, font: "data/fonts/TimeburnerBold.ttf"}
        args.outputs.labels << {x: 30, y: args.grid.h * 0.9 , text: "Press R to Restart"              , r: 255, g: 255, b: 255, font: "data/fonts/TimeburnerBold.ttf"}
    end

    def text
        "Victory for #{winning_player}"
    end

    def restart(args)
        args.state.scene = Game.new(args)
    end
end