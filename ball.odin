package pong

import "core:math"
import sdl "vendor:sdl3"

BALL_HEIGHT :: 15
BALL_WIDTH :: 15
BALL_SPEED :: 300

init_ball :: proc() -> GameEntity {
    return GameEntity{
        velocity = Vector2{0.0, 0.0},
        position = Vector2{400.0, 300.0},
        height = BALL_HEIGHT,
        width = BALL_WIDTH,
    }
}

render_ball :: proc(renderer: ^sdl.Renderer, ball: GameEntity) {
    rect := sdl.FRect{
        x = ball.position[0],
        y = ball.position[1],
        w = ball.width,
        h = ball.height,
    }
    
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)
    sdl.RenderFillRect(renderer, &rect)
}

launch_ball :: proc(ball: ^GameEntity) {
    ball.velocity[0] = BALL_SPEED
    ball.velocity[1] = BALL_SPEED
}

update_ball :: proc(ball: ^GameEntity, delta_time: f64) {
    ball.position = ball.position + ball.velocity * f32(delta_time)
}

ball_bounce_horizontally :: proc(ball: ^GameEntity) {
    ball.velocity[0] = ball.velocity[0] * -1.0
}

ball_bounce_vertically :: proc(ball: ^GameEntity) {
    ball.velocity[1] = ball.velocity[1] * -1.0
}

vector_length :: proc(velocity: Vector2) -> f32 {
    return math.sqrt(math.pow(velocity[0], 2) + math.pow(velocity[1], 2))
}

normalize :: proc(velocity: Vector2, speed: f32) -> Vector2 {
    x_velocity_normalize := velocity[0] / speed
    y_velocity_normalize := velocity[1] / speed

    return Vector2{x_velocity_normalize, y_velocity_normalize}
}

increase_ball_speed :: proc(ball: ^GameEntity) {
    speed := vector_length(ball.velocity)
    direction := normalize(ball.velocity, speed)

    speed *= 1.03
    
    ball.velocity = direction * speed
}

get_ball_edges :: proc(ball: ^GameEntity) -> (f32, f32, f32, f32) {
    ball_left := ball.position[0]
    ball_right := ball.position[0] + ball.width
    ball_top := ball.position[1]
    ball_bottom := ball.position[1] + ball.height

    return ball_left, ball_right, ball_top, ball_bottom
}

get_ball_center :: proc(ball: ^GameEntity) -> Vector2 {
    x := ball.position[0] + ball.width / 2
    y := ball.position[1] + ball.height / 2

    return Vector2{x, y}
}

check_window_collision :: proc(ball: ^GameEntity, window_width: f32, window_height: f32) {
    horizontal_window_bound := window_width - ball.width
    ball_reached_horizontal_bounds := ball.position[0] > horizontal_window_bound || ball.position[0] < 0.0
    if ball_reached_horizontal_bounds {
        ball_bounce_horizontally(ball)
    } 

    vertical_window_bound := window_height - ball.height
    ball_reached_vertical_bounds := ball.position[1] > vertical_window_bound || ball.position[1] < 0.0
    if ball_reached_vertical_bounds {
        ball_bounce_vertically(ball)
    }
}

check_paddle_collision :: proc(ball: ^GameEntity, player: ^GameEntity, cpu: ^GameEntity) {
    ball_left, ball_right, ball_top, ball_bottom := get_ball_edges(ball)

    player_left, player_right, player_top, player_bottom := get_paddle_edges(player)
    ball_collides_with_player_paddle := ball_right > player_left && ball_left < player_right && ball_bottom > player_top && ball_top < player_bottom

    cpu_left, cpu_right, cpu_top, cpu_bottom := get_paddle_edges(cpu)
    ball_collides_with_cpu_paddle := ball_right > cpu_left && ball_left < cpu_right && ball_bottom > cpu_top && ball_top < cpu_bottom

    if ball_collides_with_player_paddle {
        ball_bounce_horizontally(ball)
        increase_ball_speed(ball)
        ball.position[0] = player_right
    } else if ball_collides_with_cpu_paddle {
        ball_bounce_horizontally(ball)
        increase_ball_speed(ball)
        ball.position[0] = cpu_left - ball.width
    }
}

check_ball_collision :: proc(ball: ^GameEntity, player: ^GameEntity, cpu: ^GameEntity, window_width: f32, window_height: f32) {
    check_window_collision(ball, window_width, window_height)
    check_paddle_collision(ball, player, cpu)
}