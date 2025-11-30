# frozen_string_literal: true

require 'app/v.rb'
require 'app/ui.rb'

require 'app/objects.rb'
require 'app/scene.rb'

# CONFIG_PATH = 'config.json'
DEBUG = false
FONT = 'data/fonts/TimeburnerBold.ttf'
THEME = {
  dark: {
    primary: { r: 235, g: 235, b: 235 },
    secondary: { r: 20, g: 20, b: 20 },
    tertiary: { r: 200, g: 200, b: 200 }
  },
  light: {
    primary: { r: 20, g: 20, b: 20  },
    secondary: { r: 235, g: 235, b: 235 },
    tertiary: { r: 55, g: 55, b: 55 }
  },
  aqua: {
    primary: { r: 0, g: 160, b: 145 },
    secondary: { r: 20, g: 20, b: 20 },
    tertiary: { r: 0, g: 120, b: 100 }
  }
}.freeze

# DEFAULT_CONFIG = {
#   'sound' => true,
#   'theme' => ':dark',
#   'fullscreen' => true,
#   'two_p_mode' => false,
#   'p1_and_p2_speed' => 3,
#   'ai1_and_ai2_speed' => 1.4,
#   'win_threshhold' => 10
# }.freeze
# CONFIG_KEYS = DEFAULT_CONFIG.keys

def tick(args)
  initialize(args) if args.state.tick_count.freeze.zero?
  window(args)

  args.state.scene.update(args)
  args.state.scene.draw(args)
end

def initialize(args)
  # Settings
  args.state.fullscreen = true
  args.state.sound             = true
  args.state.two_p_mode        = false
  args.state.p1_and_p2_speed   = 3
  args.state.ai1_and_ai2_speed = 1.4
  args.state.win_threshhold    = 10
  args.state.theme             = :dark

  # Values for the Program
  args.state.countdown         = 0
  args.state.rounddelay        = 3
  args.state.last_set_time     = 0
  args.state.scene             = MainMenu.new(args)

  args.gtk.queue_sound 'data/sound/click-button.mp3' if args.state.sound
end

def window(args)
  args.state.scene = MainMenu.new(args) if args.inputs.keyboard.key_held.escape && args.state.scene != MainMenu
  args.gtk.set_window_fullscreen args.state.fullscreen
  args.outputs.background_color = THEME.fetch(args.state.theme).fetch(:secondary).values_at(:r, :g, :b)
end
