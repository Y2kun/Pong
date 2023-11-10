class MainMenu
    include Themed
    attr_accessor :ai1, :ai2, :ball
    def initialize(args)
        @ai1 = Ai1.new(args)
        @ai2 = Ai2.new(args)
        @ball = args.state.ball = Ball.new(args, @ai1, @ai2, [V[0, 3], V[0, -3]].sample)
        @offset = [0] * 4
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
            #args.outputs.borders << primary(args).merge(button) #for seeing the interactible area
            if args.inputs.mouse.intersect_rect?(button)
                @offset[index] = 5
                if args.inputs.mouse.click
                    case index
                    when 0
                        args.state.scene = Game.new(args)
                    when 1
                        args.gtk.notify! "This is not implimented yet"
                    when 2
                        args.state.scene = Options.new(args)
                    when 3
                        args.gtk.request_quit
                    end
                end
            else
                @offset[index] = 0
            end
        end
    end

    def draw(args)
        @ai1.draw(args)
        @ai2.draw(args)
        @ball.draw(args)

        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.1, y: args.grid.h * 0.85, text: "Pong", size_enum: 15, font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.15 - @offset[0], y: args.grid.h * 0.75, text: "New Game"     , size_enum: 5 + @offset[0], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.15 - @offset[1], y: args.grid.h * 0.7 , text: "Continue Game", size_enum: 5 + @offset[1], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.15 - @offset[2], y: args.grid.h * 0.65, text: "Options"      , size_enum: 5 + @offset[2], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.15 - @offset[3], y: args.grid.h * 0.6 , text: "Quit Game"    , size_enum: 5 + @offset[3], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w - 100, y: 50, text: "by Y2kun", font: FONT)
    end
end

class Options
    include Themed
    attr_accessor :ai1, :ai2, :ball, :tone
    def initialize(args)
        @ai1 = Ai1.new(args)
        @ai2 = Ai2.new(args)
        @ball = args.state.ball = Ball.new(args, @ai1, @ai2, [V[0, 3], V[0, -3]].sample)
        @offset = [0] * 6
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
            #args.outputs.borders << primary(args).merge(box)
            if args.inputs.mouse.intersect_rect?(box)
                @offset[index] = 5
            else
                @offset[index] = 0
            end
        end

        @buttons.each_with_index do |button, index|
            if args.inputs.mouse.intersect_rect?(button) && args.inputs.mouse.click
                case index
                when 0 
                    args.state.fullscreen = !args.state.fullscreen
                when 1
                    args.state.sound      = !args.state.sound
                when 2
                    args.state.two_p_mode = !args.state.two_p_mode
                when 3
                    args.gtk.notify! "This is not implimented yet"
                when 4
                    args.gtk.notify! "This is not implimented yet"
                when 5
                    args.gtk.notify! "This is not implimented yet"
                end
            end
        end
    end

    def draw(args)
        @ai1.draw(args)
        @ai2.draw(args)
        @ball.draw(args)
        #Text
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.45            , y: args.grid.h * 0.9 , text: "Options"       , size_enum: 15             , font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.3 - @offset[0], y: args.grid.h * 0.75, text: "Fullscreen"    , size_enum: 5  + @offset[0], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.3 - @offset[1], y: args.grid.h * 0.65, text: "Sound"         , size_enum: 5  + @offset[1], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.3 - @offset[2], y: args.grid.h * 0.55, text: "2 Player"      , size_enum: 5  + @offset[2], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.3 - @offset[3], y: args.grid.h * 0.45, text: "Required Score", size_enum: 5  + @offset[3], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.3 - @offset[4], y: args.grid.h * 0.35, text: "Player Speeds" , size_enum: 5  + @offset[4], font: FONT)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.3 - @offset[5], y: args.grid.h * 0.25, text: "Ai Speeds"     , size_enum: 5  + @offset[5], font: FONT)
        #Buttons
        @buttons.each_with_index do |button, index|
            args.outputs.borders << primary(args).merge(button)
            case index
            when 0
                args.outputs.solids  << primary(args).merge({x: args.grid.w * 0.25 + 7.5, y: args.grid.h * 0.75 - 33, w: 35, h: 35}) if args.state.fullscreen
            when 1
                args.outputs.solids  << primary(args).merge({x: args.grid.w * 0.25 + 7.5, y: args.grid.h * 0.65 - 33, w: 35, h: 35}) if args.state.sound
            when 2
                args.outputs.solids  << primary(args).merge({x: args.grid.w * 0.25 + 7.5, y: args.grid.h * 0.55 - 33, w: 35, h: 35}) if args.state.two_p_mode
            end
        end
        args.outputs.labels << primary(args).merge(x: 50, y: 50, text: "Esc to return to Main Menu", font: FONT)
    end
end

class Game
    include Themed
    attr_accessor :left, :right, :ball, :tone
    def initialize(args)
        @left = Player1.new(args)
        if args.state.two_p_mode
            @right = Player2.new(args)
        else
            @right = Ai2.new(args)
        end
        @ball = args.state.ball = Ball.new(args, @left, @right, [V[0, 1], V[0, -1]].sample)
        args.state.countdown = args.state.rounddelay
        args.state.last_set_time = Time.now()
    end

    def update(args)
        if winning_player = winner(args)
            args.state.scene = Win.new(args, winning_player)
            return
        end

        if args.state.last_set_time + args.state.countdown <= Time.new()
            @left.update(args)
            @right.update(args)
            @ball.update(args)
        end
    end

    def draw(args)
        @left.draw(args)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.31, y: args.grid.h - 30, text: "#{@left}: #{@left.score}", size_enum: 2)
        @right.draw(args)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.61, y: args.grid.h - 30, text: "#{@right}: #{@right.score}", size_enum: 2)
        @ball.draw(args)
        args.outputs.labels << primary(args).merge(x: 50, y: 50, text: "Esc to return to Main Menu", font: FONT)
        unless args.state.last_set_time + args.state.countdown <= Time.new()
            args.outputs.labels << primary(args).merge(x: args.grid.w * 0.5 - 10, y: args.grid.h * 0.65, text: "#{(args.state.last_set_time + args.state.countdown - Time.new()).ceil()}", font: FONT, size_enum: 30)
        end
    end

    def winner(args)
        [@left, @right].compact.find{|e| e.score >= args.state.win_threshhold }
    end
end

class Win
    include Themed
    attr_accessor :winning_player

    def initialize(args, winning_player)
        @winning_player = winning_player
        FONT = args.state.font
    end

    def update(args)
        restart(args) if args.inputs.keyboard.key_held.r
    end

    def draw(args)
        args.outputs.primitives << secondary(args).merge(primitive_marker: :solid, x: 0, y: 0, w: args.grid.w, h: args.grid.h)
        args.outputs.labels << primary(args).merge(x: args.grid.w * 0.4 , y: args.grid.h * 0.5 + 55, text: text, size_enum: 4)
        args.outputs.labels << primary(args).merge(x: 30, y: args.grid.h * 0.95, text: "Press Esc to return to Main Menu", font: FONT)
        args.outputs.labels << primary(args).merge(x: 30, y: args.grid.h * 0.9 , text: "Press R to Restart"              , font: FONT)
    end

    def text
        "Victory for #{winning_player}"
    end

    def restart(args)
        args.state.scene = Game.new(args)
    end
end