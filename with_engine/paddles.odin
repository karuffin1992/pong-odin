package pong

import "core:math"
import s_engine "sleipnir:engine"
import s_math "sleipnir:calculation"
import s_geometry "sleipnir:geometry"
import s_graphics "sleipnir:graphics"

PADDLE_WIDTH :: 16
PADDLE_HEIGHT :: 128
PADDLE_SPEED :: 300
PADDLE_SECTIONS :: 8

init_player_paddle :: proc(window_height: f32) -> GameEntity {
    y_position := (window_height / 2) - (PADDLE_HEIGHT / 2)
    return GameEntity{
        velocity = s_math.Vector2{0.0, 0.0},
        rectangle = s_geometry.Rectangle{
            position = s_math.Vector2{50.0, y_position},
            height = PADDLE_HEIGHT,
            width = PADDLE_WIDTH,
        }
    }
}

init_cpu_paddle :: proc(window_height: f32) -> GameEntity {
    y_position := (window_height / 2) - (PADDLE_HEIGHT / 2)
    return GameEntity{
        velocity = s_math.Vector2{0.0, 0.0},
        rectangle = s_geometry.Rectangle{
            position = s_math.Vector2{735.0, y_position},
            height = PADDLE_HEIGHT,
            width = PADDLE_WIDTH,
        }
    }
}

render_paddle :: proc(engine: ^s_engine.Engine, paddle: GameEntity) {
    color := s_graphics.Color{
        r = 255,
        g = 255,
        b = 255,
        a = 255
    }
    s_graphics.draw_rectangle(engine.renderer, paddle.rectangle, color)
}

move_paddle_up :: proc(paddle: ^GameEntity, delta_time: f64) {
    paddle.rectangle.position[1] -= PADDLE_SPEED * f32(delta_time)
    if paddle.rectangle.position[1] < 0.0 {
        paddle.rectangle.position[1] = 0.0
    }
}

move_paddle_down :: proc(paddle: ^GameEntity, delta_time: f64, window_height: f32) {
    paddle.rectangle.position[1] += PADDLE_SPEED * f32(delta_time)
    if paddle.rectangle.position[1] > window_height - paddle.rectangle.height {
        paddle.rectangle.position[1] = window_height - paddle.rectangle.height
    }
}

update_ai :: proc(ai_paddle: ^GameEntity, ball: ^GameEntity, is_started: bool, delta_time: f64, window_height: f32) {
    if !is_started {
        return
    }

    ball_center := s_geometry.rectangle_center(&ball.rectangle)
    paddle_center := s_geometry.rectangle_center(&ai_paddle.rectangle)
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

get_paddle_section :: proc(paddle: ^GameEntity, ball: ^GameEntity) -> int {
    paddle_section_increments := f32(PADDLE_HEIGHT / PADDLE_SECTIONS)
    
    ball_center_y := s_geometry.rectangle_center(&ball.rectangle)[1]
    paddle_position_top := paddle.rectangle.position[1]

    paddle_collision_position := ball_center_y - paddle_position_top

    section := math.floor(paddle_collision_position / paddle_section_increments)

    if section < 0 {
        section = 0
    } else if section > PADDLE_SECTIONS - 1 {
        section = PADDLE_SECTIONS - 1
    } 

    return int(section)
}
