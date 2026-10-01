package pong

import sdl "vendor:sdl3"

Vector2 :: [2]f32

GameEntity :: struct {
    velocity: Vector2,
    position: Vector2,
    height: f32,
    width: f32,
}

GameState :: struct {
    is_running: bool,
    is_started: bool, 
    player: GameEntity,
    cpu: GameEntity,
    ball: GameEntity,
    player_score: int,
    cpu_score: int,
    keys_pressed: map[sdl.Keycode]bool
}