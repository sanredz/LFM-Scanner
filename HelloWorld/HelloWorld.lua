T = {}
T_length = 0
Dungeon_interest = {}
Role_interest = {}
LFM = {"LFM", "LF1", "LF2", "LF1M", "LF2M", "LF"}
DPS = {"DD", "DPS", "DMG"}
Tank = {"TANK"}
Heal = {"HEAL", "HEALER"}

local f = CreateFrame("Frame", "LFMFrame", UIParent)
f:SetSize(250,170)
f:SetPoint("CENTER", -200, 0)
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
--f:SetUserPlaced(true)
--f:SetResizable(true)
--[[
f:SetMinResize(200,130)
f:SetMaxResize(500,400)
]]--

f.texture = f:CreateTexture()
f.texture:SetAllPoints(f)
f.texture:SetColorTexture(0, 0, 0, 0.7)

f:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
f:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

f.Text = f:CreateFontString()
f.Text:SetFontObject(GameFontHighlight)
f.Text:SetPoint("TOPLEFT", 8,-8)
f.Text:SetJustifyH("LEFT")
f.Text:SetText("NAME : DUNGEON : ROLE\n")

local resizeButton = CreateFrame("Button", nil, f)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
 
--[[
resizeButton:SetScript("OnMouseDown", function(self, button)
    f:StartSizing("BOTTOMRIGHT")
    f:SetUserPlaced(true)
end)
 
resizeButton:SetScript("OnMouseUp", function(self, button)
    f:StopMovingOrSizing()
end)
]]-- Commented out until resizing with minresize is fixed

function UpdateDungeon()
    local table = f.Text:GetText()
    for k, v in pairs(T) do
        table = table..k.." : "..v.."\n"
    end
    T = {}
    f.Text:SetText(table)
end

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

function f:ADDON_LOADED(_, addOnName)
    if addOnName == "HelloWorld" then
        PrintInfo()
    end
end

function PrintInfo()
    print("List current Dungeons/Roles: !list\nAdd Dungeon: !d *name*\nAdd Role: !r *name*\nClear LFM: !LFMclear\nClear Dungeons: !dclear\nClear Roles: !rclear\nSet role: !DPS/!TANK/!HEAL")
end

function f:CHAT_MSG_CHANNEL(event, text, playerName)

    if T_length < 9 then
        local fin = false
        for l = 1, #LFM do
            if string.find(string.upper(text), LFM[l]) then
                local info = ""
                for i = 1, #Dungeon_interest do
                    if string.find(string.upper(text), Dungeon_interest[i]) then
                        info = Dungeon_interest[i]
                        for j = 1, #Role_interest do
                            if string.find(string.upper(text), string.upper(Role_interest[j])) then
                                info = info.." : "..Role_interest[j]
                                local playerNameTrimmed = string.gsub(playerName, "-Stitches", "")
                                T[playerNameTrimmed] = string.upper(info)
                                T_length = T_length + 1
                                UpdateDungeon()
                                fin = true
                                break
                            end
                        end
                        break
                    end
                    if fin then
                        break
                    end
                end
                break
            end
            if fin then
                break
            end
        end
    end
end

function f:CHAT_MSG_SAY(event, text)
    if string.upper(text) == "!DPS" then
        Role_interest = DPS
    end
    if string.upper(text) == "!TANK" then
        Role_interest = Tank
    end
    if string.upper(text) == "!HEAL" then
        Role_interest = Heal
    end
    if string.upper(text) == "!LFMCLEAR" then
        f.Text:SetText("NAME : DUNGEON : ROLE\n")
    end
    if string.upper(text) == "!LIST" then
        print("-=DUNGEONS=-")
        local d = ""
        for i = 1, #Dungeon_interest do
            d = d .. " " .. Dungeon_interest[i]
        end
        print(d.."\n")
        print("-=ROLES=-")
        local r = ""
        for i = 1, #Role_interest do
            r = r .. " " .. Role_interest[i]
        end
        print(r.."\n")
    end
    if string.upper(text) == "!RCLEAR" then
        Role_interest = {}
    end
    if string.upper(text) == "!DCLEAR" then
        Dungeon_interest = {}
    end
    if string.find(string.upper(text), "!R ") then
        local d = string.gsub(string.upper(text), "!R ", "")
        table.insert(Role_interest, d)
    end
    if string.find(string.upper(text), "!D ") then
        local d = string.gsub(string.upper(text), "!D ", "")
        table.insert(Dungeon_interest, d)
    end
end


f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("CHAT_MSG_SAY")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

