package pong

import "core:math"
import s_engine "sleipnir:engine"
import s_math "sleipnir:calculation"
import s_geometry "sleipnir:geometry"
import s_graphics "sleipnir:graphics"

BALL_HEIGHT :: 15
BALL_WIDTH :: 15
BALL_SPEED :: 300
MAX_ANGLE :: 60

init_ball :: proc() -> GameEntity {
    return GameEntity{
        velocity = s_math.Vector2{0.0, 0.0},
        rectangle = s_geometry.Rectangle{
            position = s_math.Vector2{400.0, 300.0},
            height = BALL_HEIGHT,
            width = BALL_WIDTH,
        }
    }
}

render_ball :: proc(engine: ^s_engine.Engine, ball: GameEntity) {
    color := s_graphics.Color{
        r = 255,
        g = 255,
        b = 255,
        a = 255
    }
    s_graphics.draw_rectangle(engine.renderer, ball.rectangle, color)
}

launch_ball :: proc(ball: ^GameEntity) {
    ball.velocity[0] = BALL_SPEED
    ball.velocity[1] = BALL_SPEED
}

update_ball :: proc(ball: ^GameEntity, delta_time: f64) {
    ball.rectangle.position = ball.rectangle.position + ball.velocity * f32(delta_time)
}

get_angle :: proc(section: int) -> f32 {
    // Need to factor both positive and negative ranges
    angle_increment := (MAX_ANGLE * 2) / f32(PADDLE_SECTIONS - 1)
    return -MAX_ANGLE + angle_increment * f32(section)
}

get_bounce_velocity :: proc(section: int, speed: f32, direction: f32) -> s_math.Vector2 {
    angle := math.to_radians(get_angle(section))

    velocity_x := speed * math.cos(angle) * direction
    velocity_y := speed * math.sin(angle)

    return s_math.Vector2{velocity_x, velocity_y}
}

ball_bounce_horizontally :: proc(ball: ^GameEntity) {
    ball.velocity[0] = ball.velocity[0] * -1.0
}

ball_bounce_vertically :: proc(ball: ^GameEntity) {
    ball.velocity[1] = ball.velocity[1] * -1.0
}

check_window_collision :: proc(ball: ^GameEntity, window_width: f32, window_height: f32) {
    horizontal_window_bound := window_width - ball.rectangle.width
    ball_reached_horizontal_bounds := ball.rectangle.position[0] > horizontal_window_bound || ball.rectangle.position[0] < 0.0
    if ball_reached_horizontal_bounds {
        ball_bounce_horizontally(ball)
    } 

    vertical_window_bound := window_height - ball.rectangle.height
    ball_reached_vertical_bounds := ball.rectangle.position[1] > vertical_window_bound || ball.rectangle.position[1] < 0.0
    if ball_reached_vertical_bounds {
        ball_bounce_vertically(ball)
    }
}

check_paddle_collision :: proc(ball: ^GameEntity, player: ^GameEntity, cpu: ^GameEntity) {
    _, player_right, _, _ := s_geometry.rectangle_edges(&player.rectangle)
    cpu_left, _, _, _ := s_geometry.rectangle_edges(&cpu.rectangle)
    ball_collides_with_player_paddle := s_geometry.rectangle_overlap(&ball.rectangle, &player.rectangle)
    ball_collides_with_cpu_paddle := s_geometry.rectangle_overlap(&ball.rectangle, &cpu.rectangle)

    if ball_collides_with_player_paddle {
        speed := s_math.get_vector_length(&ball.velocity)
        speed *= 1.03
        section := get_paddle_section(player, ball)
        ball.velocity = get_bounce_velocity(section, speed, +1)
        ball.rectangle.position[0] = player_right
    } else if ball_collides_with_cpu_paddle {
        speed := s_math.get_vector_length(&ball.velocity)
        speed *= 1.03
        section := get_paddle_section(cpu, ball)
        ball.velocity = get_bounce_velocity(section, speed, -1)
        ball.rectangle.position[0] = cpu_left - ball.rectangle.width
    }
}

check_ball_collision :: proc(ball: ^GameEntity, player: ^GameEntity, cpu: ^GameEntity, window_width: f32, window_height: f32) {
    check_window_collision(ball, window_width, window_height)
    check_paddle_collision(ball, player, cpu)
}