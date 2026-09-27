package pong

import "core:fmt"
import sdl "vendor:sdl3"

PADDLE_WIDTH :: 15
PADDLE_HEIGHT :: 100
PADDLE_SPEED :: 300

init_player_paddle :: proc(window_height: f32) -> GameEntity {
    y_position := (window_height / 2) - (PADDLE_HEIGHT / 2)
    return GameEntity{
        velocity = Vector2{0.0, 0.0},
        position = Vector2{50.0, y_position},
        height = PADDLE_HEIGHT,
        width = PADDLE_WIDTH,
    }
}

init_cpu_paddle :: proc(window_height: f32) -> GameEntity {
    y_position := (window_height / 2) - (PADDLE_HEIGHT / 2)
    return GameEntity{
        velocity = Vector2{0.0, 0.0},
        position = Vector2{735.0, y_position},
        height = PADDLE_HEIGHT,
        width = PADDLE_WIDTH,
    }
}

render_paddle :: proc(renderer: ^sdl.Renderer, paddle: GameEntity) {
    rect := sdl.FRect{
        x = paddle.position[0],
        y = paddle.position[1],
        w = paddle.width,
        h = paddle.height,
    }

    sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
    sdl.RenderFillRect(renderer, &rect)
}

move_paddle_up :: proc(paddle: ^GameEntity, delta_time: f64) {
    paddle.position[1] -= PADDLE_SPEED * f32(delta_time)
    if paddle.position[1] < 0.0 {
        paddle.position[1] = 0.0
    }
}

move_paddle_down :: proc(paddle: ^GameEntity, delta_time: f64, window_height: f32) {
    paddle.position[1] += PADDLE_SPEED * f32(delta_time)
    if paddle.position[1] > window_height - paddle.height {
        paddle.position[1] = window_height - paddle.height
    }
}

get_paddle_edges :: proc(paddle: ^GameEntity) -> (f32, f32, f32, f32) {
    paddle_left := paddle.position[0]
    paddle_right := paddle.position[0] + paddle.width
    paddle_top := paddle.position[1]
    paddle_bottom := paddle.position[1] + paddle.height

    return paddle_left, paddle_right, paddle_top, paddle_bottom
}

get_paddle_center :: proc(paddle: ^GameEntity) -> Vector2 {
    x := paddle.position[0] + paddle.width / 2
    y := paddle.position[1] + paddle.height / 2

    return Vector2{x, y}
}

update_ai :: proc(ai_paddle: ^GameEntity, ball: ^GameEntity, is_started: bool, delta_time: f64, window_height: f32) {
    if !is_started {
        return
    }

    ball_center := get_ball_center(ball)
    paddle_center := get_paddle_center(ai_paddle)
    dead_zone := f32(25)
    
    // Ball moving away from CPU, move toward center
    if ball.velocity[0] <= 0 {
        window_height_middle := window_height / 2

        if paddle_center[1] > window_height_middle {
            move_paddle_up(ai_paddle, delta_time)
        } else if paddle_center[1] < window_height_middle {
            move_paddle_down(ai_paddle, delta_time, window_height)
        }
    } else {
        // Ball moving toward CPU, track ball
        if ball_center[1] < paddle_center[1] - dead_zone {
            move_paddle_up(ai_paddle, delta_time)
        } else if ball_center[1] > paddle_center[1] + dead_zone{
            move_paddle_down(ai_paddle, delta_time, window_height)
        }
    }
}