local character = script.Parent
local humanoid = character.Parent:WaitForChild("Humanoid")

local MSC = require(character:WaitForChild("MovementStateController"))

-- helpers
local function waitForAttribute(instance, attributeName)
	while instance:GetAttribute(attributeName) == nil do
		instance:GetAttributeChangedSignal(attributeName):Wait()
	end
	return instance:GetAttribute(attributeName)
end

-- stats
local acceleration = waitForAttribute(character, "Acceleration")
local walkSpeed = waitForAttribute(character, "WalkSpeed")
local runSpeed = waitForAttribute(character, "RunSpeed")

-- services
local RunService = game:GetService("RunService")

local currentSpeed = humanoid.WalkSpeed
local targetSpeed = walkSpeed

RunService.Heartbeat:Connect(function(dt)
  local state = MSC.getCurrentState()

  print(state)

  if state == MSC.getStates().Idle then
		targetSpeed = 0

	elseif state == MSC.getStates().Walking then
		targetSpeed = walkSpeed

	elseif state == MSC.getStates().Sprinting then
		targetSpeed = runSpeed
	end
  
	currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * math.clamp(dt * acceleration, 0, 1)
	humanoid.WalkSpeed = currentSpeed
end)