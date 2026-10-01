package pong

import "core:fmt"
import s_engine "sleipnir:engine"
import s_graphics "sleipnir:graphics"
import s_calculation "sleipnir:calculation"

render_player_score :: proc(engine: ^s_engine.Engine, font_key: string, player_score: int) {
    text := fmt.ctprint(player_score)
    text_color := s_graphics.Color{255, 255, 255, 255}

    center_x := f32(engine.config.window_resolution[0]) / 4.0
    position := s_calculation.Vector2{center_x, 25}

    s_graphics.draw_text(engine.renderer, text, engine.fonts[font_key], text_color, position)
}

render_cpu_score :: proc(engine: ^s_engine.Engine, font_key: string, cpu_score: int) {
    text := fmt.ctprint(cpu_score)
    text_color := s_graphics.Color{255, 255, 255, 255}

    center_x := f32(engine.config.window_resolution[0]) * 2.75 / 4.0
    position := s_calculation.Vector2{center_x, 25}

    s_graphics.draw_text(engine.renderer, text, engine.fonts[font_key], text_color, position)
}

render_score :: proc(engine: ^s_engine.Engine, font_key: string, player_score: int, cpu_score: int) {
    render_player_score(engine, font_key, player_score)
    render_cpu_score(engine, font_key, cpu_score)
}