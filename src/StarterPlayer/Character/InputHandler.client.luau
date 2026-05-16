local character = script.Parent
local MSC = require(character:WaitForChild("MovementStateController"))

MSC.init()

local UIS = game:GetService("UserInputService")

local movementKeys = {
  [Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true
}

local heldKeys = {}

local states = MSC.getStates()

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

  local state = MSC.getCurrentState()

	if movementKeys[input.KeyCode] then
    heldKeys[input.KeyCode] = true

    if state == states.Idle or state == states.Walking then
      MSC.setState(MSC.getStates().Walking)
    end
  end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		MSC.setState(MSC.getStates().Sprinting)
	end
end)

local function isStillMoving()
	for _, v in pairs(heldKeys) do
		if v then
			return true
		end
	end
	return false
end

UIS.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	local key = input.KeyCode

	-- remove movement key first (if it is one)
	if movementKeys[key] then
		heldKeys[key] = nil

		if not isStillMoving() then
			MSC.setState(MSC.getStates().Idle)
		end
		return
	end

	-- shift logic
	if key == Enum.KeyCode.LeftShift then
		if isStillMoving() then
			MSC.setState(MSC.getStates().Walking)
		else
			MSC.setState(MSC.getStates().Idle)
		end
	end
end)