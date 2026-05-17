local character = script.Parent
local humanoid = character.Parent:WaitForChild("Humanoid")
local hrp = character.Parent:WaitForChild("HumanoidRootPart")

local MSC = require(character:WaitForChild("MovementStateController"))
local states = MSC.getStates()

-- helpers
local function waitForAttribute(instance, attributeName)
	while instance:GetAttribute(attributeName) == nil do
		instance:GetAttributeChangedSignal(attributeName):Wait()
	end
	return instance:GetAttribute(attributeName)
end

-- stats
local acceleration = waitForAttribute(character, "Acceleration")

local slideSpeed = waitForAttribute(character, "SlideSpeed")
local crouchSpeed = waitForAttribute(character, "CrouchSpeed")

local slideVelocity = 0
local groundNormal = Vector3.yAxis
local lockedSlideDirection = Vector3.zero

-- vars

local previousState

-- sliding
local normalHipHeight = humanoid.HipHeight
local crouchHipHeight = normalHipHeight * 0.5
local slideFriction = waitForAttribute(character, "SlideFriction")
local slideEndSpeed = crouchSpeed + 2

local slideVelocity = 0
local slopeBoost = 300
local groundNormal

-- services
local RunService = game:GetService("RunService")

local currentSpeed = humanoid.WalkSpeed
local targetSpeed = 0

-- SLIDING

local function startSlide() 
	humanoid.HipHeight = crouchHipHeight
	slideVelocity = slideSpeed

	local look = hrp.CFrame.LookVector
  local flatLook = Vector3.new(look.X, 0, look.Z)
  lockedSlideDirection = flatLook.Magnitude > 0.001 and flatLook.Unit or look

	local impulse = lockedSlideDirection * slideSpeed
	hrp.AssemblyLinearVelocity = Vector3.new(impulse.X, hrp.AssemblyLinearVelocity.Y, impulse.Z)
end

local function startCrouch()
	humanoid.HipHeight = crouchHipHeight
	slideVelocity = 0
end

local function endCrouch() 
	humanoid.HipHeight = normalHipHeight
end



local function standardMovement(state, dt)
	-- if state ~= states.Idle and state ~= states.Walking and state ~= states.Sprinting then return end
	local targetSpeed = MSC.getTargetSpeed()

	-- sliding logic
	if state == states.Sliding then
		local slopeInfluence = -groundNormal:Dot(lockedSlideDirection)

		print(slopeInfluence)

		local gravityAcceleration = workspace.Gravity * 0.4 * slopeInfluence

		local drag = slideFriction * slideVelocity * slideVelocity

		slideVelocity = slideVelocity + (gravityAcceleration + drag) * dt
		slideVelocity = math.max(slideVelocity, 0)

		local moveVelocity = lockedSlideDirection *	slideVelocity
		hrp.AssemblyLinearVelocity = Vector3.new(
        moveVelocity.X,
        hrp.AssemblyLinearVelocity.Y,
        moveVelocity.Z
    )

		-- print(slideVelocity)

		if slideVelocity <= slideEndSpeed then
			MSC.setState(states.Crouching)
		end

		targetSpeed = slideVelocity
	end

	currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * math.clamp(dt * acceleration, 0, 1)
	humanoid.WalkSpeed = currentSpeed
end

local function crouchMovement(state)
	if state == states.Crouching and previousState ~= states.Crouching then
		startCrouch()
	end
	if state == states.Sliding and previousState ~= states.Sliding then
		startSlide()
	end
	if (previousState == states.Sliding or previousState == states.Crouching) and (state ~= states.Sliding and state ~= states.Crouching) then
		endCrouch()
	end
end

RunService.Heartbeat:Connect(function(dt)
	local state = MSC.getCurrentState()

	print(state)

	-- Add to Heartbeat loop
	local floorRay = workspace:Raycast(hrp.Position, Vector3.new(0, -(humanoid.HipHeight + 1.5), 0), rayParams)
	if floorRay then
			groundNormal = floorRay.Normal
	end

	crouchMovement(state)
  standardMovement(state, dt)

	previousState = state
end)