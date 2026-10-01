package pong

import sdl "vendor:sdl3"

record_events :: proc(game_state: ^GameState) {
    // using this to track keyboard actions and window actions
    event := sdl.Event{}
    for sdl.PollEvent(&event) {
        #partial switch event.type {
            case .QUIT:
                game_state.is_running = false
            case .KEY_DOWN:
                switch event.key.key {
                case sdl.K_ESCAPE:
                    game_state.is_running = false
                case sdl.K_SPACE:
                    game_state.keys_pressed[sdl.K_SPACE] = true
                case sdl.K_W:
                    game_state.keys_pressed[sdl.K_W] = true
                case sdl.K_S:
                    game_state.keys_pressed[sdl.K_S] = true
                }
            case .KEY_UP:
                switch event.key.key {
                case sdl.K_ESCAPE:
                    game_state.is_running = false
                case sdl.K_SPACE:
                    game_state.keys_pressed[sdl.K_SPACE] = false
                case sdl.K_W:
                    game_state.keys_pressed[sdl.K_W] = false            
                case sdl.K_S:
                    game_state.keys_pressed[sdl.K_S] = false
                }
        }
    }
}