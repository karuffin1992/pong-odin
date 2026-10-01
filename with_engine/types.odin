package pong

import s_math "sleipnir:calculation"
import s_geometry "sleipnir:geometry"

GameEntity :: struct {
    velocity: s_math.Vector2,
    rectangle: s_geometry.Rectangle
}

GameState :: struct {
    is_started: bool, 
    player: GameEntity,
    cpu: GameEntity,
    ball: GameEntity,
    player_score: int,
    cpu_score: int
}

PongContext :: struct {
    game_state: ^GameState
}