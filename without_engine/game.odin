package pong

import "core:fmt"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"

init_game_state :: proc(game_state: ^GameState, window_height: f32) {
    fmt.println("initializing game entities")
    game_state^ = GameState{
        is_running = true,
        is_started = false, 
        player = init_player_paddle(window_height),
        cpu = init_cpu_paddle(window_height),
        ball = init_ball(),
        player_score = 0,
        cpu_score = 0,
        keys_pressed = make(map[sdl.Keycode]bool)
    }
}

reset_game :: proc(game_state: ^GameState, window_height: f32) {
    new_game_state := GameState{
        is_running = game_state.is_running,
        is_started = false, 
        player = init_player_paddle(window_height),
        cpu = init_cpu_paddle(window_height),
        ball = init_ball(),
        player_score = game_state.player_score,
        cpu_score = game_state.cpu_score,
        keys_pressed = game_state.keys_pressed
    }

    game_state^ = new_game_state
}

render :: proc(renderer: ^sdl.Renderer, font: ^ttf.Font, game_state: GameState, window_width: f32) {
    // set background color to black and clear the screen
    sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
    sdl.RenderClear(renderer)

    // render game entities
    render_paddle(renderer, game_state.player)
    render_paddle(renderer, game_state.cpu)
    render_ball(renderer, game_state.ball)
    render_score(renderer, font, window_width, game_state.player_score, game_state.cpu_score)

    // present the rendered frame
    sdl.RenderPresent(renderer)
}

check_if_goal_score :: proc(game_state: ^GameState, window_width: f32) -> bool {
    scored := false
    ball_left, ball_right, _, _ := get_ball_edges(&game_state.ball)

    if ball_left <= 0 {
        fmt.println("cpu scored")
        game_state.cpu_score += 1
        scored = true
    } else if ball_right >= window_width {
        fmt.println("player scored")
        game_state.player_score += 1
        scored = true
    }

    return scored
}

update :: proc(game_state: ^GameState, delta_time: f64, window_height: f32, window_width: f32) {
    if game_state.keys_pressed[sdl.K_SPACE] {
        launch_ball(&game_state.ball)
        game_state.is_started = true
    }
    
    if game_state.keys_pressed[sdl.K_W] {
        move_paddle_up(&game_state.player, delta_time)
    }

    if game_state.keys_pressed[sdl.K_S] {
        move_paddle_down(&game_state.player, delta_time, window_height)
    }

    update_ai(&game_state.cpu, &game_state.ball, game_state.is_started, delta_time, window_height)
    update_ball(&game_state.ball, delta_time)
    check_ball_collision(&game_state.ball, &game_state.player, &game_state.cpu, window_width, window_height)
    
    if check_if_goal_score(game_state, window_width) {
        reset_game(game_state, window_height)
        return
    }
}
