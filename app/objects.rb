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
    attr_accessor :width, :heigth, :left, :right, :tone, :pos, :velocity, :speed, :possible_sounds
    def initialize(args, left, right)
        @width = 25
        @heigth = 25
        @left = left
        @right = right
        @pos = V[args.grid.w * 0.5 - @width * 0.5, args.grid.h * 0.5 - @heigth * 0.5]
        @velocity = V[[5, -5].sample, [1, -1].sample]
        @speed = 2
        @possible_sounds = ["ball-hit",]
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
        args.gtk.queue_sound "data/sound/score.mp3" if args.state.sound
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
        args.gtk.queue_sound "data/sound/#{possible_sounds.sample}.mp3" if args.state.sound
    end
end

class ReactiveLabel
    include Themed
    attr_accessor :text, :pos, :size, :w, :h, :is_offset, :offset_amount
    def initialize(args, text, pos, size)
        @text = text
        @pos = pos
        @size = size
        @w, @h = args.gtk.calcstringbox(@text, @size, FONT)
        @is_offset = false
        @offset_amount = 5
    end

    def update(args)
        if args.inputs.mouse.intersect_rect?({x: @pos.x, y: @pos.y - @h, w: @w, h: @h})
            @is_offset = true
        else
            @is_offset = false
        end
    end

    def draw(args)
        if @is_offset
            pos = @pos - V[@offset_amount, 0]
            size = @size + @offset_amount
            w, h = args.gtk.calcstringbox(@text, size, FONT)

            args.outputs.labels  << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
            args.outputs.borders << primary(args).merge(x: pos.x, y: pos.y - h, w: w, h: h) if DEBUG
        else
            args.outputs.labels  << primary(args).merge(x: @pos.x, y: @pos.y, text: @text, size_enum: @size, font: FONT)
            args.outputs.borders << primary(args).merge(x: @pos.x, y: @pos.y - @h, w: @w, h: @h) if DEBUG
        end
    end
end

class ClickableReactiveLabel
    include Themed
    attr_accessor :text, :pos, :size, :w, :h, :is_offset, :on_click, :offset_amount
    def initialize(args,text, pos, size, on_click)
        @text = text
        @pos = pos
        @size = size
        @w, @h = args.gtk.calcstringbox(@text, @size, FONT)
        @is_offset = false
        @on_click = on_click
        @offset_amount = 5
    end

    def update(args)
        if args.inputs.mouse.intersect_rect?({x: @pos.x, y: @pos.y - @h, w: @w, h: @h})
            @is_offset = true
            if args.inputs.mouse.click
                @on_click && @on_click.call(args)
                args.gtk.queue_sound "data/sound/click-button.mp3" if args.state.sound
            end
        else
            @is_offset = false
        end
    end

    def draw(args)
        if @is_offset
            pos = @pos - V[@offset_amount, 0]
            size = @size + @offset_amount
            w, h = args.gtk.calcstringbox(@text, size, FONT)

            args.outputs.labels  << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
            args.outputs.borders << primary(args).merge(x: pos.x, y: pos.y - h, w: w, h: h) if DEBUG
        else
            args.outputs.labels  << primary(args).merge(x: @pos.x, y: @pos.y, text: @text, size_enum: @size, font: FONT)
            args.outputs.borders << primary(args).merge(x: @pos.x, y: @pos.y - @h, w: @w, h: @h) if DEBUG
        end
    end
end

class SwitchWithLabel
    include Themed
    attr_accessor :text, :pos, :switch_width, :switch_height, :text_size, :text_width, :text_height, :enable_condition, :is_offset
    def initialize(args, text, pos, switch_width, switch_height, text_size, enable_condition)
        @text = text
        @switch_pos = pos
        @switch_width = switch_width
        @switch_height = switch_height
        @text_size = text_size
        @text_width, @text_height = args.gtk.calcstringbox(@text, @text_size, FONT)
        @text_pos = V[@switch_pos.x + @switch_width * 1.15, @switch_pos.y + @switch_height * 0.8]
        @enable_condition = enable_condition
        @is_offset = false
        @offset_amount = 5
    end

    def update(args)
        if args.inputs.mouse.intersect_rect?(x: @text_pos.x - @switch_width, y: @text_pos.y - @text_height, w: @text_width * 1.7, h: @text_height)
            @is_offset = true
        else
            @is_offset = false
        end         

        if args.inputs.mouse.intersect_rect?(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height) && args.inputs.mouse.click
            case args.state.send(@enable_condition)
            when NilClass
                args.gtk.notify! "Error: No Enable Condition set for Object Swl, with the text [ #{@text} ]"
                puts "Swl stands for Switch with label"
            when String
                args.gtk.notify! "Error: Enable Condition for Object Swl, with the text [ #{@text} ], is a String"
                puts "Swl stands for Switch with label"
            when true, false
                args.state.send("#{@enable_condition}=", !args.state.send(@enable_condition))
                args.gtk.queue_sound "data/sound/click-button.mp3" if args.state.sound
            else
                puts args.state.send(@enable_condition)
            end
        end
    end

    def draw(args)
        args.outputs.solids  << primary(args).merge(x: @switch_pos.x + @switch_width * 0.15, y: @switch_pos.y + @switch_height * 0.15,
                                                    w: @switch_width * 0.7, h: @switch_height * 0.7) if args.state.send(@enable_condition)
        args.outputs.borders << primary(args).merge(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height)

        if @is_offset
            pos = @text_pos - V[@offset_amount, 0]
            size = @text_size + @offset_amount
            w, h = args.gtk.calcstringbox(@text, size, FONT)

            args.outputs.labels  << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
            args.outputs.borders << primary(args).merge(x: pos.x - @switch_width, y: pos.y - @text_height, w: w + @switch_width, h: @text_height) if DEBUG
        else
            args.outputs.labels  << primary(args).merge(x: @text_pos.x, y: @text_pos.y, text: @text, size_enum: @text_size, font: FONT)
            args.outputs.borders << primary(args).merge(x: @text_pos.x, y: @text_pos.y - @text_height, w: @text_width, h: @text_height) if DEBUG
        end
    end
end

# class IncrementableLabel
#     include Themed
#     attr_accessor :text, :pos, :switch_width, :switch_height, :text_size, :text_width, :text_height, :enable_condition, :is_offset
#     def initialize(args, text, pos, switch_width, switch_height, text_size, enable_condition)
#         @text = text
#         @switch_pos = pos
#         @switch_width = switch_width
#         @switch_height = switch_height
#         @text_size = text_size
#         @text_width, @text_height = args.gtk.calcstringbox(@text, @text_size, FONT)
#         @text_pos = V[@switch_pos.x + @switch_width * 1.15, @switch_pos.y + @switch_height * 0.8]
#         @enable_condition = enable_condition
#         @is_offset = false
#         @offset_amount = 5
#     end

#     def update(args)
#         if args.inputs.mouse.intersect_rect?(x: @text_pos.x - @switch_width, y: @text_pos.y - @text_height, w: @text_width * 1.7, h: @text_height)
#             @is_offset = true
#         else
#             @is_offset = false
#         end

#         if args.inputs.mouse.intersect_rect?(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height) && args.inputs.mouse.click
#             case args.state.send(@enable_condition)
#             when NilClass
#                 puts "Error: No Enable Condition set for Object Swl, with the text [ #{@text} ]"
#                 puts "Swl stands for Switch with label"
#             when String
#                 puts "Error: Enable Condition for Object Swl, with the text [ #{@text} ], is a String"
#                 puts "Swl stands for Switch with label"
#             when true, false
#                 args.state.send("#{@enable_condition}=", !args.state.send(@enable_condition))
#             else
#                 puts args.state.send(@enable_condition)
#             end
#         end
#     end

#     def draw(args)
#         args.outputs.solids  << primary(args).merge(x: @switch_pos.x + @switch_width * 0.15, y: @switch_pos.y + @switch_height * 0.15,
#                                                     w: @switch_width * 0.7, h: @switch_height * 0.7) if args.state.send(@enable_condition)
#         args.outputs.borders << primary(args).merge(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height)

#         if @is_offset
#             pos = @text_pos - V[@offset_amount, 0]
#             size = @text_size + @offset_amount
#             w, h = args.gtk.calcstringbox(@text, size, FONT)

#             args.outputs.labels  << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
#             args.outputs.borders << primary(args).merge(x: pos.x - @switch_width, y: pos.y - @text_height, w: w + @switch_width, h: @text_height) if DEBUG
#         else
#             args.outputs.labels  << primary(args).merge(x: @text_pos.x, y: @text_pos.y, text: @text, size_enum: @text_size, font: FONT)
#             args.outputs.borders << primary(args).merge(x: @text_pos.x, y: @text_pos.y - @text_height, w: @text_width, h: @text_height) if DEBUG
#         end
#     end
# end