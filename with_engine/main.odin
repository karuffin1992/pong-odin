package pong

import "core:fmt"
import s_engine "sleipnir:engine"
import s_font "sleipnir:font"
import s_input "sleipnir:input"
import platform "sleipnir:platform"
import time "sleipnir:time"

main :: proc() {
    fmt.println("pong!")

    fps := 60
    engine := s_engine.Engine{
        config = s_engine.EngineConfig{
            window_resolution = [2]i32{800, 600},
            window_title = "Pong",
            target_fps = i32(fps),
        },
        timing = time.init_loop_timing(fps),
        input = s_input.init(),
        fonts = make(map[string]s_font.Font),
        state = s_engine.EngineState{
            is_running = true
        }
    }

    platform.init_sdl()
    platform.init_ttf()
    platform.init_window_and_renderer(&engine)

    fonts := map[string]s_font.FontConfig{}
    fonts["game"] = s_font.FontConfig{
        path = "assets/VT323-Regular.ttf",
        size = 64,
    }
    platform.init_fonts(&engine, fonts)

    game_state := GameState{}
    init_game_state(&game_state, f32(engine.config.window_resolution[1]))

    pong_context := PongContext{
        game_state = &game_state,
    }

    updateFn := _update
    renderFn := _render
    s_engine.run_game_loop(&engine, rawptr(&pong_context), updateFn, renderFn)

    platform.quit_process(&engine)
}
