package pong

import "core:fmt"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600
WINDOW_TITLE :: "Pong"
FPS :: 60

WINDOW: ^sdl.Window
RENDERER: ^sdl.Renderer
FONT: ^ttf.Font
GAME_STATE: GameState

init_sdl :: proc() {
    fmt.println("initializing SDL")
    sdlOk := sdl.Init(sdl.INIT_VIDEO); assert(sdlOk, "Failed to initialize SDL")

    fmt.println("initializing SDL_TTF")
    ttfOk := ttf.Init(); assert(ttfOk, "Failed to initialize SDL_TTF")
    
    fmt.println("creating game window and renderer")
    sdlWindowAndRenderer := sdl.CreateWindowAndRenderer(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, sdl.WINDOW_RESIZABLE, &WINDOW, &RENDERER); assert(sdlWindowAndRenderer, "Failed to create window")

    fmt.println("opening font")
    FONT = ttf.OpenFont("assets/VT323-Regular.ttf", 64); assert(FONT != nil, "Failed to load font")
}

quit_process :: proc(renderer: ^sdl.Renderer, window: ^sdl.Window, font: ^ttf.Font) {
    fmt.println("quitting SDL")
    sdl.DestroyRenderer(renderer)
    sdl.DestroyWindow(window)
    ttf.CloseFont(font)
    ttf.Quit()
    sdl.Quit()
}

run_game_loop :: proc(game_state: ^GameState, renderer: ^sdl.Renderer, font: ^ttf.Font, fps: int, window_height: f32, window_width: f32) {
 // establish clock
    previous_time := sdl.GetTicksNS()
    // accumulator is used to keep track of the time that has passed since the last update
    accumulator: f64 = 0.0
    // fixed_delta_time is the time that should pass between each update, based on the desired FPS
    fixed_delta_time: f64 = 1.0 / f64(fps)

    for game_state.is_running {
        // get the current time and calculate the delta time (in nanoseconds) since the last frame,
        // then move the previous time forward for the next frame
        current_time := sdl.GetTicksNS()
        delta_time := current_time - previous_time
        previous_time = current_time

        // convert delta time to seconds and add it to the accumulator
        delta_seconds := f64(delta_time) / 1_000_000_000.0
        accumulator += delta_seconds

        record_events(game_state)
        
        // if our accumlated time is greater than our targeted FPS time, then update the game
        // in N amount of allowed ticks
        for accumulator >= fixed_delta_time {
            update(game_state, fixed_delta_time, window_height, window_width)
            accumulator -= fixed_delta_time
        }

        render(renderer, font, game_state^, window_width)
    }
}

main :: proc() {
    fmt.println("pong!")

    init_sdl()
    init_game_state(&GAME_STATE, WINDOW_HEIGHT)
    run_game_loop(&GAME_STATE, RENDERER, FONT, FPS, WINDOW_HEIGHT, WINDOW_WIDTH)
    quit_process(RENDERER, WINDOW, FONT)
}
