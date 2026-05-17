local character = script.Parent
local MSC = require(character:WaitForChild("MovementStateController"))

local UIS = game:GetService("UserInputService")

local movementKeys = {
  [Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
}

local heldKeys = {}

local states = MSC.getStates()

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	local key = input.KeyCode

  local state = MSC.getCurrentState()

	if movementKeys[key] then
    heldKeys[key] = true

    if state == states.Idle or state == states.Walking then
      MSC.setState(MSC.getStates().Walking)
    end
  end

	if key == Enum.KeyCode.LeftShift then
		MSC.setState(MSC.getStates().Sprinting)
	end

	if key == Enum.KeyCode.C then
		if state == states.Sprinting then
			MSC.setState(MSC.getStates().Sliding)
		elseif state == states.Walking or state == states.Idle then
			MSC.setState(MSC.getStates().Crouching)
		end
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
	local state = MSC.getCurrentState()

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
    if state ~= states.Sliding and state ~= states.Crouching then
        if isStillMoving() then
            MSC.setState(states.Walking)
        else
            MSC.setState(states.Idle)
        end
    end
	end

	if key == Enum.KeyCode.C then
    if state == states.Crouching or state == states.Sliding then
        if isStillMoving() then
            MSC.setState(states.Walking)
        else
            MSC.setState(states.Idle)
        end
    end
	end
end)