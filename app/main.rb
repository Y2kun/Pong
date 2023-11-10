require "app/v.rb"
require "app/scene.rb"
require "app/objects.rb"

FONT = "data/fonts/TimeburnerBold.ttf"

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
    args.state.theme             = :dark
    args.state.two_p_mode        = false
    args.state.p1_and_p2_speed   = 4
    args.state.ai1_and_ai2_speed = 1.2
    args.state.win_threshhold    = 10 #How many Points are required for Victory
    #saves
    args.state.running           = true
    args.state.countdown         = 0
    args.state.rounddelay        = 3
    args.state.tone              = {}
    args.state.tone[:dark]       = [{r: 0, g: 0, b: 0}, {r: 255, g: 255, b: 255}]
    args.state.tone[:light]      = [{r: 255, g: 255, b: 255}, {r: 0, g: 0, b: 0}]
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