local MovementStateController = {}

-- helper
local function waitForAttribute(instance, attributeName)
	while instance:GetAttribute(attributeName) == nil do
		instance:GetAttributeChangedSignal(attributeName):Wait()
	end
	return instance:GetAttribute(attributeName)
end

local character = script.Parent

local targetSpeed = 0

-- states

local States = {
  Idle     = "Idle",
  Walking  = "Walking",
  Crouching = "Crouching",
  Sprinting = "Sprinting",
  Sliding  = "Sliding",
  Jumping  = "Jumping",
  Airborne  = "Airborne",
  WallRunning = "WallRunning",
  Climbing = "Climbing",
}

local currentState = States.Idle

-- speeds
local walkSpeed = waitForAttribute(character, "WalkSpeed")
local runSpeed = waitForAttribute(character, "RunSpeed")
local crouchSpeed = waitForAttribute(character, "CrouchSpeed")

function MovementStateController.setState(newState)
  -- Enter new state
  currentState = newState

  -- Set target speed if applicable
  if newState == States.Idle        then targetSpeed = 0            end
  if newState == States.Walking     then targetSpeed = walkSpeed    end
  if newState == States.Sprinting   then targetSpeed = runSpeed     end
  if newState == States.Crouching   then targetSpeed = crouchSpeed  end
  -- if newState == States.Sliding     then startSlide() end
  -- if newState == States.WallRunning then startWallrun() end
  -- if newState == States.Climbing    then startClimb() end
end

function MovementStateController.getTargetSpeed()
  return targetSpeed
end

function MovementStateController.getCurrentState()
	return currentState
end

function MovementStateController.getStates()
	return States
end

return MovementStateController