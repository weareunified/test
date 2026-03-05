local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function SetCore(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = "rbxassetid://71516332224921",
            Duration = 5
        })
    end)
end

local hookm = hookmetamethod
local hookf = hookfunction
local ncc = newcclosure
local cc = checkcaller
local gnm = getnamecallmethod

if not (hookm and hookf and ncc) then
    return
end

-- Block detection remotes and intercepted kicks via namecall
local OldNamecall; OldNamecall = hookm(game, "__namecall", ncc(function(self, ...)
    if cc() then return OldNamecall(self, ...) end
    
    local method = gnm()
    local cleanMethod = string.gsub(method, "%z.*", "")

    if (cleanMethod == "FireServer" or cleanMethod == "InvokeServer") then
        local name = tostring(self)
        local ln = string.lower(name)
        if string.match(ln, "ban") or string.match(ln, "kick") or string.match(ln, "flag") or string.match(ln, "log") or string.match(ln, "report") or string.match(ln, "check") or string.match(ln, "detect") then
            SetCore("Lumin Hub", "Blocked Detection Remote: " .. name)
            return nil 
        end
    end

    if rawequal(self, LocalPlayer) and (string.gsub(cleanMethod, "^%l", string.upper) == "Kick" or string.lower(cleanMethod) == "kick") then
        SetCore("Lumin Hub", "Intercepted kick attempt.")
        return nil
    end

    return OldNamecall(self, ...)
end))

-- Block direct Kick calls
local OldKick; OldKick = hookf(LocalPlayer.Kick, ncc(function(self, ...)
    if not cc() then
        SetCore("Lumin Hub", "Intercepted direct kick.")
        return nil
    end
    return OldKick(self, ...)
end))

-- Block debug.info detection (Anti-External/Anti-Hook)
if debug and debug.info then
    local oldDebugInfo; oldDebugInfo = hookf(debug.info, ncc(function(...)
        if not cc() then
            return nil
        end
        return oldDebugInfo(...)
    end))
end

-- Block detection via Instance.new("RemoteEvent") which then fires immediately
local oldInstanceNew; oldInstanceNew = hookf(Instance.new, ncc(function(class, parent)
    if not cc() and (class == "RemoteEvent" or class == "RemoteFunction") then
        local ins = oldInstanceNew(class, parent)
        SetCore("Lumin Hub", "Blocked dynamic detection remote.")
        return oldInstanceNew("BindableEvent")
    end
    return oldInstanceNew(class, parent)
end))

task.spawn(function()
    local s = os.clock()
    while os.clock() - s < 15 do
        if pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Lumin Hub", Text="Advanced Anti-Cheat Bypass Active", Duration=5, Icon = "rbxassetid://71516332224921"}) end) then
            break
        end
        task.wait(1)
    end
end)
