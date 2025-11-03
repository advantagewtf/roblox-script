-- CallbackLib.lua
local CallbackLib = {}
CallbackLib.__index = CallbackLib

-- Roblox Services Cache (IY-style)
local Services = setmetatable({}, {
    __index = function(self, name)
        local success, service = pcall(function()
            return game:GetService(name)
        end)
        if success then
            rawset(self, name, service)
            return service
        else
            warn("Invalid Roblox service: " .. tostring(name))
        end
    end
})

-- Stores all registered callbacks
CallbackLib._callbacks = {}

-- Create a new callback type (event)
function CallbackLib:CreateCallback(name)
    if not self._callbacks[name] then
        self._callbacks[name] = {}
    end

    return {
        Connect = function(_, fn)
            assert(typeof(fn) == "function", "Callback must be a function")
            table.insert(self._callbacks[name], fn)
        end
    }
end

-- Fire all functions bound to an event
function CallbackLib:Fire(name, ...)
    local cbs = self._callbacks[name]
    if not cbs then return end
    for _, fn in ipairs(cbs) do
        task.spawn(fn, ...)
    end
end

-------------------------------------------------------
-- 🔹 Built-in Roblox event hooks
-------------------------------------------------------
local Players = Services.Players
local RunService = Services.RunService

-- PlayerAdded
Players.PlayerAdded:Connect(function(player)
    CallbackLib:Fire("onPlayerAdded", player)

    -- CharacterAdded / Removing
    player.CharacterAdded:Connect(function(char)
        CallbackLib:Fire("onCharacterAdded", player, char)
    end)

    player.CharacterRemoving:Connect(function(char)
        CallbackLib:Fire("onCharacterRemoving", player, char)
    end)

    -- Chat messages
    local success, msgEvent = pcall(function()
        return player.Chatted
    end)
    if success and msgEvent then
        msgEvent:Connect(function(message)
            CallbackLib:Fire("onChatMessage", player, message)
        end)
    end
end)

-- PlayerRemoving
Players.PlayerRemoving:Connect(function(player)
    CallbackLib:Fire("onPlayerRemoved", player)
end)

-- RenderStep (every frame)
RunService.RenderStepped:Connect(function(delta)
    CallbackLib:Fire("onRenderStep", delta)
end)

-------------------------------------------------------
-- 🔹 Example usage (you can delete this in prod)
-------------------------------------------------------
--[[
CallbackLib:CreateCallback("onPlayerAdded"):Connect(function(plr)
    print("[Callback] Player joined:", plr.Name)
end)

CallbackLib:CreateCallback("onChatMessage"):Connect(function(plr, msg)
    print(plr.Name .. " said:", msg)
end)

CallbackLib:CreateCallback("onRenderStep"):Connect(function(dt)
    -- print("Frame update:", dt)
end)
]]

return CallbackLib
