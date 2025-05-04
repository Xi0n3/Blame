class_name PlayerStatesNames extends Resource

#region OnGround
const Idle:String = "PlayerStateIdle"
const Walking:String = "PlayerStateWalking"
const Running:String = "PlayerStateRunning"
const Sprinting:String = "PlayerStateSprinting"

#Momento donde el jugador acaba de tocar el piso
const Landing:String = "PlayerStateLanding"

const AttackGround:String = "PlayerStateAttackGround"
#endregion

#region OnAir
const Jumping:String = "PlayerStateJumping"
#Cuando el jugador cae, pero aún puede realizar acciones como saltar o dash.
const Falling:String = "PlayerStateFalling"
#El jugador cae y no puede hcaer nada hasta tocar el suelo
const FreeFalling:String = "PlayerStateFreeFalling"
#endregion

#region Actions
const Dashing:String = "PlayerStateDashing"
#endregion

#region Reactions
#Cuando el jugador recibe un golpe y este retrocede o cae
const HitStun = "PlayerStateHitStun"
const Dead = "PlayerStateDead"
#endregion
