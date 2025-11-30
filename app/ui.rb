# frozen_string_literal: true

# Helper to easily select the colors
module Themed
  def primary(args)
    THEME.fetch(args.state.theme).fetch(:primary)
  end

  def secondary(args)
    THEME.fetch(args.state.theme).fetch(:secondary)
  end

  def tertiary(args)
    THEME.fetch(args.state.theme).fetch(:tertiary)
  end
end

# generalized, except FONT
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
    @is_offset = args.inputs.mouse.intersect_rect?({ x: @pos.x, y: @pos.y - @h, w: @w, h: @h }) || false
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

# NOTE: when reused need to change many things
# Label which can be clicked, also changes size and position based on hover
class ClickableReactiveLabel
  include Themed
  attr_accessor :text, :pos, :size, :w, :h, :is_offset, :on_click, :offset_amount

  def initialize(args, text, pos, size, on_click)
    @text = text
    @pos = pos
    @size = size
    @w, @h = args.gtk.calcstringbox(@text, @size, FONT)
    @is_offset = false
    @on_click = on_click
    @offset_amount = 5
  end

  def update(args)
    if args.inputs.mouse.intersect_rect?({ x: @pos.x, y: @pos.y - @h, w: @w, h: @h })
      @is_offset = true
      if args.inputs.mouse.click
        @on_click&.call(args)
        args.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
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

# NOTE: when reused need to change many things
# Label with a toggle box
class SwitchWithLabel
  include Themed
  attr_accessor :text, :pos, :switch_width, :switch_height, :text_size, :text_width, :text_height, :enable_condition,
                :is_offset

  def initialize(args, text, pos, switch_width, switch_height, text_size, enable_condition)
    @text = text
    @switch_pos = pos
    @switch_width = switch_width
    @switch_height = switch_height
    @text_size = text_size
    @text_width, @text_height = args.gtk.calcstringbox(@text, @text_size, FONT)
    @text_pos = V[@switch_pos.x + (@switch_width * 1.15), @switch_pos.y + (@switch_height * 0.8)]
    @enable_condition = enable_condition
    @is_offset = false
    @offset_amount = 5
  end

  def update(args)
    @is_offset = args.inputs.mouse.intersect_rect?(x: @text_pos.x - @switch_width, y: @text_pos.y - @text_height,
                                                   w: @text_width * 1.7, h: @text_height) || false

    if args.inputs.mouse.intersect_rect?(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width,
                                         h: @switch_height) && args.inputs.mouse.click
      case args.state.send(@enable_condition)
      when NilClass
        args.gtk.notify! "Error: No Enable Condition set for Object Swl, with the text [ #{@text} ]"
        puts 'Swl stands for Switch with label'
      when String
        args.gtk.notify! "Error: Enable Condition for Object Swl, with the text [ #{@text} ], is a String"
        puts 'Swl stands for Switch with label'
      when true, false
        args.state.send("#{@enable_condition}=", !args.state.send(@enable_condition))
        args.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
      else
        puts args.state.send(@enable_condition)
      end
    end
  end

  def draw(args)
    if args.state.send(@enable_condition)
      args.outputs.solids << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.15), y: @switch_pos.y + (@switch_height * 0.15),
                                                 w: @switch_width * 0.7, h: @switch_height * 0.7)
    end
    args.outputs.borders << primary(args).merge(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height)

    if @is_offset
      pos = @text_pos - V[@offset_amount, 0]
      size = @text_size + @offset_amount
      w, = args.gtk.calcstringbox(@text, size, FONT)

      args.outputs.labels << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
      if DEBUG
        args.outputs.borders << primary(args).merge(x: pos.x - @switch_width, y: pos.y - @text_height,
                                                    w: w + @switch_width, h: @text_height)
      end
    else
      args.outputs.labels << primary(args).merge(x: @text_pos.x, y: @text_pos.y, text: @text, size_enum: @text_size,
                                                 font: FONT)
      if DEBUG
        args.outputs.borders << primary(args).merge(x: @text_pos.x, y: @text_pos.y - @text_height, w: @text_width,
                                                    h: @text_height)
      end
    end
  end
end

# NOTE: when reused need to change many things
# Label which has a incremend and decrement button
class SimpleArithmaticLabel
  include Themed
  attr_accessor :text, :pos, :switch_width, :switch_height, :text_size, :text_width, :text_height, :var_change_amount,
                :changing_var, :is_offset

  def initialize(args, text, pos, switch_width, switch_height, text_size, var_change_amount, changing_var)
    @text = text
    @switch_pos = pos
    @switch_width = switch_width
    @switch_height = switch_height
    @text_size = text_size
    @text_width, @text_height = args.gtk.calcstringbox(@text, @text_size, FONT)
    @text_pos = V[@switch_pos.x + (@switch_width * 1.15), @switch_pos.y + (@switch_height * 0.8)]
    @changing_var = changing_var
    @var_change_amount = var_change_amount
    @is_offset = false
    @offset_amount = 5
  end

  def update(args)
    @is_offset = args.inputs.mouse.intersect_rect?(x: @text_pos.x - (@switch_width * 3), y: @text_pos.y - @text_height,
                                                   w: @text_width * 2.28, h: @text_height) || false

    return unless args.inputs.mouse.click

    if args.inputs.mouse.intersect_rect?(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height)
      args.state.send("#{@changing_var}=", args.state.send(@changing_var) + @var_change_amount)
      args.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
    end

    if args.state.send(@changing_var).positive? && args.inputs.mouse.intersect_rect?(x: @switch_pos.x - 100,
                                                                                     y: @switch_pos.y, w: @switch_width, h: @switch_height)
      args.state.send("#{@changing_var}=", args.state.send(@changing_var) - @var_change_amount)
      args.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
    end
  end

  def draw(args)
    args.outputs.borders << primary(args).merge(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height)
    args.outputs.solids  << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.15), y: @switch_pos.y + (@switch_height * 0.45),
                                                w: @switch_width * 0.7, h: @switch_height * 0.1)
    args.outputs.solids  << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.45), y: @switch_pos.y + (@switch_height * 0.15),
                                                w: @switch_width * 0.1, h: @switch_height * 0.7)
    args.outputs.borders << primary(args).merge(x: @switch_pos.x - 100, y: @switch_pos.y, w: @switch_width,
                                                h: @switch_height)
    args.outputs.solids  << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.15) - 100, y: @switch_pos.y + (@switch_height * 0.45),
                                                w: @switch_width * 0.7, h: @switch_height * 0.1)
    number = args.state.send(@changing_var).round(1)
    @number_text_width, @number_text_height = args.gtk.calcstringbox(@text, @text_size, FONT)
    args.outputs.labels << primary(args).merge(x: @switch_pos.x - (@switch_width * 0.66),
                                               y: @switch_pos.y + @number_text_height, text: number, size_enum: @text_size, font: FONT)

    if @is_offset
      pos = @text_pos - V[@offset_amount, 0]
      size = @text_size + @offset_amount
      w, = args.gtk.calcstringbox(@text, size, FONT)

      args.outputs.labels << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
      if DEBUG
        args.outputs.borders << primary(args).merge(x: pos.x - (@switch_width * 3), y: pos.y - @text_height,
                                                    w: w + (@switch_width * 3), h: @text_height)
      end
    else
      args.outputs.labels << primary(args).merge(x: @text_pos.x, y: @text_pos.y, text: @text, size_enum: @text_size,
                                                 font: FONT)
      if DEBUG
        args.outputs.borders << primary(args).merge(x: @text_pos.x, y: @text_pos.y - @text_height, w: @text_width,
                                                    h: @text_height)
      end
    end
  end
end

# NOTE: when reused need to change many things
# Changes the content based on the current cycle
class CyclableLabel
  include Themed
  attr_accessor :text, :pos, :switch_width, :switch_height, :text_size, :text_width, :text_height, :changing_var,
                :var_options, :current_option, :option_index, :is_offset

  def initialize(args, text, pos, switch_width, switch_height, text_size, changing_var, var_options)
    @text = text
    @switch_pos = pos
    @switch_width = switch_width
    @switch_height = switch_height
    @text_size = text_size
    @text_width, @text_height = args.gtk.calcstringbox(@text, @text_size, FONT)
    @text_pos = V[@switch_pos.x + (@switch_width * 1.15), @switch_pos.y + (@switch_height * 0.8)]
    @changing_var = changing_var
    @var_options = var_options
    @option_index = @var_options.find_index(args.state.send(@changing_var))
    @current_option = @var_options[@option_index]
    @is_offset = false
    @offset_amount = 5
  end

  def update(args)
    @is_offset = args.inputs.mouse.intersect_rect?(x: @text_pos.x - (@switch_width * 3), y: @text_pos.y - @text_height,
                                                   w: @text_width * 2.28, h: @text_height) || false

    return unless args.inputs.mouse.click

    if @option_index < @var_options.count - 1 && args.inputs.mouse.intersect_rect?(x: @switch_pos.x,
                                                                                   y: @switch_pos.y, w: @switch_width, h: @switch_height)
      option_index
      rgs.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
    end

    if @option_index.positive? && args.inputs.mouse.intersect_rect?(x: @switch_pos.x - 100, y: @switch_pos.y,
                                                                    w: @switch_width, h: @switch_height)
      @option_index -= 1
      args.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
    end

    @current_option = @var_options[@option_index]
    args.state.send("#{@changing_var}=", @current_option)
  end

  def draw(args)
    args.outputs.borders << primary(args).merge(x: @switch_pos.x, y: @switch_pos.y, w: @switch_width, h: @switch_height)
    args.outputs.solids  << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.15), y: @switch_pos.y + (@switch_height * 0.45),
                                                w: @switch_width * 0.7, h: @switch_height * 0.1)
    args.outputs.solids  << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.45), y: @switch_pos.y + (@switch_height * 0.15),
                                                w: @switch_width * 0.1, h: @switch_height * 0.7)
    args.outputs.borders << primary(args).merge(x: @switch_pos.x - 100, y: @switch_pos.y, w: @switch_width,
                                                h: @switch_height)
    args.outputs.solids  << primary(args).merge(x: @switch_pos.x + (@switch_width * 0.15) - 100, y: @switch_pos.y + (@switch_height * 0.45),
                                                w: @switch_width * 0.7, h: @switch_height * 0.1)

    setting = @current_option.to_s
    _, setting_height = args.gtk.calcstringbox(setting, @text_size, FONT)
    args.outputs.labels << primary(args).merge(x: @switch_pos.x - (@switch_width * 0.9),
                                               y: @switch_pos.y + setting_height, text: setting, size_enum: @text_size, font: FONT)

    if @is_offset
      pos = @text_pos - V[@offset_amount, 0]
      size = @text_size + @offset_amount
      w, = args.gtk.calcstringbox(@text, size, FONT)

      args.outputs.labels << primary(args).merge(x: pos.x, y: pos.y, text: @text, size_enum: size, font: FONT)
      if DEBUG
        args.outputs.borders << primary(args).merge(x: pos.x - (@switch_width * 3), y: pos.y - @text_height,
                                                    w: w + (@switch_width * 3), h: @text_height)
      end
    else
      args.outputs.labels << primary(args).merge(x: @text_pos.x, y: @text_pos.y, text: @text, size_enum: @text_size,
                                                 font: FONT)
      if DEBUG
        args.outputs.borders << primary(args).merge(x: @text_pos.x, y: @text_pos.y - @text_height, w: @text_width,
                                                    h: @text_height)
      end
    end
  end
end
