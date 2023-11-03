class MainMenu
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
        puts @player.speed.inspect
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
        args.outputs.labels << {x: args.grid.w * 0.5 - 100 * 0.5, y: args.grid.h - 30, text: "p1 #{@player.score}", r: 255, g: 255, b: 255}
        if args.state.two_player_mode
            @player2.draw(args)
            args.outputs.labels << {x: args.grid.w * 0.5 + 50  * 0.5, y: args.grid.h - 30, text: "p2 #{@player2.score}", r: 255, g: 255, b: 255}
        else
            @enemy.draw(args)
            args.outputs.labels << {x: args.grid.w * 0.5 + 50  * 0.5, y: args.grid.h - 30, text: "e  #{@enemy.score}", r: 255, g: 255, b: 255}
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
        args.outputs.labels << {x: args.grid.w * 0.5 - 100, y: args.grid.h * 0.5 + 55, text: text, r: 255, b: 255, g: 255}
    end

    def text
        "Victory for #{winning_player}: Score #{winning_player.score}"
    end

    def restart(args)
        args.state.scene = Game.new(args)
    end
end