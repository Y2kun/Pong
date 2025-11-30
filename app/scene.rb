# frozen_string_literal: true

# The Main Menu
class MainMenu
  include Themed
  attr_accessor :ai1, :ai2, :ball, :labels

  def initialize(args)
    @ai1 = Ai1.new(args)
    @ai2 = Ai2.new(args)
    @ball = args.state.ball = Ball.new(args, @ai1, @ai2)
    @labels = [ClickableReactiveLabel.new(args, 'New Game', V[190, 540], 5, lambda { |a|
      a.state.scene = Game.new(a)
    }),
               ClickableReactiveLabel.new(args, 'Continue Game', V[190, 500], 5, lambda { |_a|
                 puts 'Error: This is currently not implemented'
               }),
               ClickableReactiveLabel.new(args, 'Options', V[190, 460], 5, lambda { |a|
                 a.state.scene = Options.new(a)
               }),
               ClickableReactiveLabel.new(args, 'Quit Game', V[190, 420], 5, ->(a) { a.gtk.request_quit })]
  end

  def update(args)
    @ai1.update(args)
    @ai2.update(args)
    @ball.update(args)

    @labels.each_with_index do |label, _index|
      label.update(args)
    end
  end

  def draw(args)
    @ai1.draw(args)
    @ai2.draw(args)
    @ball.draw(args)

    @labels.each do |label|
      label.draw(args)
    end

    args.outputs.labels << primary(args).merge(x: 128, y: 612, text: 'Pong', size_enum: 15, font: FONT)
    args.outputs.labels << primary(args).merge(x: 1180, y: 50, text: 'by Y2kun', font: FONT)
  end
end

class Options
  include Themed
  attr_accessor :ai1, :ai2, :ball, :configs

  def initialize(args)
    @ai1 = Ai1.new(args)
    @ai2 = Ai2.new(args)
    @ball = args.state.ball = Ball.new(args, @ai1, @ai2)
    @configs = [SwitchWithLabel.new(args, 'Fullscreen', V[320, 500], 50, 50, 5, :fullscreen),
                SwitchWithLabel.new(args, 'Sound', V[320, 440], 50, 50, 5, :sound),
                SwitchWithLabel.new(args, '2 Player', V[320, 380], 50, 50, 5, :two_p_mode),
                SimpleArithmaticLabel.new(args, 'Required Score, 0 = unlimited', V[320, 320], 50, 50, 5, 1,
                                          :win_threshhold),
                SimpleArithmaticLabel.new(args, 'Player Speeds', V[320, 260], 50, 50, 5, 0.1, :p1_and_p2_speed),
                SimpleArithmaticLabel.new(args, 'Ai Speeds', V[320, 200], 50, 50, 5, 0.1, :ai1_and_ai2_speed),
                CyclableLabel.new(args, 'Theme', V[320, 140], 50, 50, 5, :theme, %i[dark light aqua])] # Read the array in the function to improve
  end

  def update(args)
    @ai1.update(args)
    @ai2.update(args)
    @ball.update(args)

    @configs.each do |config|
      config.update(args)
    end
  end

  def draw(args)
    @ai1.draw(args)
    @ai2.draw(args)
    @ball.draw(args)

    @configs.each do |config|
      config.draw(args)
    end

    args.outputs.labels << primary(args).merge(x: 575, y: 640, text: 'Options', size_enum: 15, font: FONT)
    args.outputs.labels << primary(args).merge(x: 50, y: 50, text: 'Esc to return to Main Menu', font: FONT)

    # theme
    # maybe volueme
  end
end

class Game
  include Themed
  attr_accessor :left, :right, :ball

  def initialize(args)
    @left = Player1.new(args)
    @right = if args.state.two_p_mode
               Player2.new(args)
             else
               Ai2.new(args)
             end
    @ball = args.state.ball = Ball.new(args, @left, @right)
    args.state.countdown = args.state.rounddelay
    args.state.last_set_time = Time.now
  end

  def update(args)
    if args.state.win_threshhold.positive? && winning_player = winner(args)
      args.state.scene = Win.new(args, winning_player)
    end

    return unless args.state.last_set_time + args.state.countdown <= Time.new

    @left.update(args)
    @right.update(args)
    @ball.update(args)
  end

  def draw(args)
    @left.draw(args)
    args.outputs.labels << primary(args).merge(x: 400, y: 690, text: "#{@left}: #{@left.score}", size_enum: 5,
                                               font: FONT)
    @right.draw(args)
    args.outputs.labels << primary(args).merge(x: 780, y: 690, text: "#{@right}: #{@right.score}", size_enum: 5,
                                               font: FONT)
    @ball.draw(args)
    args.outputs.labels << primary(args).merge(x: 50, y: 50, text: 'Esc to return to Main Menu', font: FONT)
    return if args.state.last_set_time + args.state.countdown <= Time.new

    args.outputs.labels << primary(args).merge(x: 630, y: 470,
                                               text: "#{(args.state.last_set_time + args.state.countdown - Time.new).ceil}", size_enum: 30, font: FONT)
  end

  def winner(args)
    [@left, @right].compact.find { |p| p.score >= args.state.win_threshhold }
  end
end

class Win
  include Themed
  attr_accessor :winning_player

  def initialize(_args, winning_player)
    @winning_player = winning_player
  end

  def update(args)
    args.state.scene = Game.new(args) if args.inputs.keyboard.key_held.r
  end

  def draw(args)
    args.outputs.primitives << secondary(args).merge(primitive_marker: :solid, x: 0, y: 0, w: args.grid.w,
                                                     h: args.grid.h)
    args.outputs.labels << primary(args).merge(x: 530, y: 420, text: "Victory for #{@winning_player}",
                                               size_enum: 10, font: FONT)
    args.outputs.labels << primary(args).merge(x: 30, y: 685, text: 'Press Esc to return to Main Menu', font: FONT)
    args.outputs.labels << primary(args).merge(x: 30, y: 650, text: 'Press R to Restart', font: FONT)
  end
end
