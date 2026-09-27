package pong

import "core:fmt"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"

render_player_score :: proc(renderer: ^sdl.Renderer, font: ^ttf.Font, window_width: f32, player_score: int) {
    text := fmt.ctprint(player_score)
    text_color := sdl.Color{255, 255, 255, 255}
    surface := ttf.RenderText_Blended(font, text, len(text), text_color); assert(surface != nil, "Failed to render score")
    texture := sdl.CreateTextureFromSurface(renderer, surface); assert(texture != nil, "failed to create score texture")

    center_x := f32(window_width) / 4.0

    rect := sdl.FRect{
        x = center_x - f32(surface.w) / 2.0,
        y = 25,
        w = f32(surface.w),
        h = f32(surface.h),
    }

    sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
    sdl.RenderFillRect(renderer, &rect)
    sdl.RenderTexture(renderer, texture, nil, &rect)
}

render_cpu_score :: proc(renderer: ^sdl.Renderer, font: ^ttf.Font, window_width: f32, cpu_score: int) {
    text := fmt.ctprint(cpu_score)
    text_color := sdl.Color{255, 255, 255, 255}
    surface := ttf.RenderText_Blended(font, text, len(text), text_color); assert(surface != nil, "Failed to render score")
    texture := sdl.CreateTextureFromSurface(renderer, surface); assert(texture != nil, "failed to create score texture")

    center_x := f32(window_width) * 3.0 / 4.0

    rect := sdl.FRect{
        x = center_x - f32(surface.w) / 2.0,
        y = 25,
        w = f32(surface.w),
        h = f32(surface.h),
    }

    sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
    sdl.RenderFillRect(renderer, &rect)
    sdl.RenderTexture(renderer, texture, nil, &rect)
}

render_score :: proc(renderer: ^sdl.Renderer, font: ^ttf.Font, window_width: f32, player_score: int, cpu_score: int) {
    render_player_score(renderer, font, window_width, player_score)
    render_cpu_score(renderer, font, window_width, cpu_score)
}