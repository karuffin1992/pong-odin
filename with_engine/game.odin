package pong

import "core:fmt"
import s_geometry "sleipnir:geometry"
import s_input "sleipnir:input"
import s_engine "sleipnir:engine"

init_game_state :: proc(game_state: ^GameState, window_height: f32) {
    fmt.println("initializing game entities")
    game_state^ = GameState{
        is_started = false, 
        player = init_player_paddle(window_height),
        cpu = init_cpu_paddle(window_height),
        ball = init_ball(),
        player_score = 0,
        cpu_score = 0
    }
}

reset_game :: proc(game_state: ^GameState, window_height: f32) {
    new_game_state := GameState{
        is_started = false, 
        player = init_player_paddle(window_height),
        cpu = init_cpu_paddle(window_height),
        ball = init_ball(),
        player_score = game_state.player_score,
        cpu_score = game_state.cpu_score
    }

    game_state^ = new_game_state
}

_render :: proc(ctx: rawptr, engine: ^s_engine.Engine) {
    pong_context := cast(^PongContext)ctx

    render(pong_context.game_state, engine)
}

render :: proc(game_state: ^GameState, engine: ^s_engine.Engine) {
    // render game entities
    render_paddle(engine, game_state.player)
    render_paddle(engine, game_state.cpu)
    render_ball(engine, game_state.ball)
    render_score(engine, "game", game_state.player_score, game_state.cpu_score)
}

check_if_goal_score :: proc(game_state: ^GameState, window_width: f32) -> bool {
    scored := false
    ball_left, ball_right, _, _ := s_geometry.rectangle_edges(&game_state.ball.rectangle)

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

_update :: proc(ctx: rawptr, engine: ^s_engine.Engine) {
    pong_context := cast(^PongContext)ctx

    update(pong_context.game_state, engine)
}

update :: proc(game_state: ^GameState, engine: ^s_engine.Engine) {
    if engine.input.quit_requested || engine.input.keyboard.keys_pressed[s_input.KeyboardKeys.Escape]{
        engine.state.is_running = false
        return
    }
    
    if !game_state.is_started && engine.input.keyboard.keys_pressed[s_input.KeyboardKeys.Space] {
        launch_ball(&game_state.ball)
        game_state.is_started = true
    }
    
    if engine.input.keyboard.keys_pressed[s_input.KeyboardKeys.W] {
        move_paddle_up(&game_state.player, engine.timing.fixed_delta_time)
    }

    if engine.input.keyboard.keys_pressed[s_input.KeyboardKeys.S] {
        move_paddle_down(&game_state.player, engine.timing.fixed_delta_time, f32(engine.config.window_resolution[1]))
    }

    update_ai(&game_state.cpu, &game_state.ball, game_state.is_started, engine.timing.fixed_delta_time, f32(engine.config.window_resolution[1]))
    update_ball(&game_state.ball, engine.timing.fixed_delta_time)
    check_ball_collision(&game_state.ball, &game_state.player, &game_state.cpu, f32(engine.config.window_resolution[0]), f32(engine.config.window_resolution[1]))
    
    if check_if_goal_score(game_state, f32(engine.config.window_resolution[0])) {
        reset_game(game_state, f32(engine.config.window_resolution[1]))
        return
    }
}
