require "app/v.rb"
require "app/objects.rb"
require "app/scene.rb"

FONT = "data/fonts/TimeburnerBold.ttf"
THEME = {
    dark: {
        primary: {r: 235, g: 235, b: 235},
        secondary: {r: 20, g: 20, b: 20},
    },
    light: {
        secondary: {r: 235, g: 235, b: 235},
        primary: {r: 20, g: 20, b: 20},
    },
}

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
    args.state.theme             = :light
    args.state.two_p_mode        = false
    args.state.p1_and_p2_speed   = 3
    args.state.ai1_and_ai2_speed = 1.2
    args.state.win_threshhold    = 1 #How many Points are required for Victory
    #saves
    args.state.countdown         = 0
    args.state.rounddelay        = 3
    args.state.scene             = MainMenu.new(args)
    args.state.last_set_time     = 0
end

def window(args)
    args.state.scene = MainMenu.new(args) if args.inputs.keyboard.key_held.escape
    args.gtk.set_window_fullscreen args.state.fullscreen
    if args.state.theme == :dark
        args.outputs.background_color = [20, 20, 20]
    else
        args.outputs.background_color = [235, 235, 235]
    end
end