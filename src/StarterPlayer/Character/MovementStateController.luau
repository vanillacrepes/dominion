local MovementStateController = {}

local States = {
  Idle     = "Idle",
  Walking  = "Walking",
  Sprinting = "Sprinting",
  Sliding  = "Sliding",
  Jumping  = "Jumping",
  Airborne  = "Airborne",
  WallRunning = "WallRunning",
  Climbing = "Climbing",
}


local function endSlide() end
local function endWallrun() end
local function endClimb() end
local function startSprint() end
local function startSlide() end
local function startWallrun() end
local function startClimb() end

function MovementStateController.init()
  currentState = States.Idle
end

function MovementStateController.setState(newState)
  -- Exit current state
  if currentState == States.Sliding   then endSlide() end
  if currentState == States.WallRunning then endWallrun() end
  if currentState == States.Climbing  then endClimb() end

  -- Enter new state
  currentState = newState

  if newState == States.Idle        then targetSpeed = 0 end
  if newState == States.Walking     then targetSpeed = walkSpeed end
  if newState == States.Sprinting   then startSprint() end
  if newState == States.Sliding     then startSlide() end
  if newState == States.WallRunning then startWallrun() end
  if newState == States.Climbing    then startClimb() end
end

function MovementStateController.getCurrentState()
	return currentState
end

function MovementStateController.getStates()
	return States
end

return MovementStateController