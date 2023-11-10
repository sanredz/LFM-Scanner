T = {}
T_length = 0
Dungeon_interest = {}
Role_interest = {}
LFM = {"LFM", "LF1", "LF2", "LF1M", "LF2M", "LF "}
DPS = {"DD", "DPS", "DMG"}
Tank = {"TANK"}
Heal = {"HEAL", "HEALER"}
Delim = {"%s","$","[&!?,./%-_()=*]"}

local f = CreateFrame("Frame", "LFMFrame", UIParent, "BackdropTemplate")
f:SetSize(250,170)
f:SetPoint("CENTER", UIParent, "CENTER")
BackdropInfo = {
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	edgeSize = 1.5,
	insets = { left = 1, right = 1, top = 1, bottom = 1, },
}
f:SetBackdrop(BackdropInfo)
f:SetBackdropColor(0.2,0.14,0,0.87) -- Black background
f:SetBackdropBorderColor(1,0.769,0.388,1) -- White border
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetUserPlaced(true)
f:SetResizable(true)
f:SetResizeBounds(200,60,300,300)
--[[ Old coloring of window, obsolete
f.texture = f:CreateTexture()
f.texture:SetAllPoints(f)
f.texture:SetColorTexture(0, 0, 0, 0.7)
]]--


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

resizeButton:SetScript("OnMouseDown", function(self, button)
    f:StartSizing("BOTTOMRIGHT")
    f:SetUserPlaced(true)
end)
resizeButton:SetScript("OnMouseUp", function(self, button)
	f:StopMovingOrSizing()
end)
 
 
--[[
resizeButton:SetScript("OnMouseDown", function(self, button)
    f:StartSizing("BOTTOMRIGHT")
    f:SetUserPlaced(true)
end)
 
resizeButton:SetScript("OnMouseUp", function(self, button)
    f:StopMovingOrSizing()
end)
]]-- Commented out until resizing with minresize is fixed

function UpdateDungeon(playerName, info)
    if GetWindowSize() then
        local table = f.Text:GetText()
        local playerNameTrimmed = string.gsub(playerName, "-Stitches", "")
        local row = playerNameTrimmed.." : "..string.upper(info)
        table = table .."\n"..row
        f.Text:SetText(table)
    end
end


function GetWindowSize()
    local enoughSpace = true
    local windowSize = f:GetHeight()
    local fontHeight = f.Text:GetStringHeight()
    if windowSize-fontHeight < 15 then
        enoughSpace = false
    end
    return enoughSpace
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
    print("All Commands: !info\nList current Dungeons/Roles: !list\nAdd Dungeon: !d *name*\nAdd Role: !r *name*\nClear LFM: !LFMclear\nClear Dungeons: !dclear\nClear Roles: !rclear\nSet role: !DPS/!TANK/!HEAL\nHide: !hide\nShow: !show")
end

function PatternMatch(interest)

end

function f:CHAT_MSG_CHANNEL(event, text, playerName)
    if T_length < 9 then
        local fin = false
        local fin2 = false
        for l = 1, #LFM do
            if string.find(string.upper(text), LFM[l]) then
                local info = ""
                for i = 1, #Dungeon_interest do
                    for d = 1, #Delim do
                        for dt = 1, #Delim do
                            if string.find(string.upper(text), Delim[d]..Dungeon_interest[i]..Delim[dt]) then
                                info = Dungeon_interest[i]
                                fin2 = true
                                break
                            end
                        end
                    end
                    if fin2 then
                        break
                    end
                end
                if fin2 then
                    for j = 1, #Role_interest do
                        for d = 1, #Delim do
                            for dt = 1, #Delim do
                                if string.find(string.upper(text), Delim[dt]..Role_interest[j]..Delim[d]) then
                                    info = info.." : "..Role_interest[j]
                                    T_length = T_length + 1
                                    UpdateDungeon(playerName, info)
                                    fin = true
                                    break
                                end
                            end
                        end
                        if fin then
                            break
                        end
                    end
                end
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
    if string.upper(text) == "!SHOW" then
        f:Show()
    end
    if string.upper(text) == "!HIDE" then
        f:Hide()
    end
    if string.upper(text) == "!INFO" then
        PrintInfo()
    end
    if string.upper(text) == "!LEN" then
        local fontHeight = f.Text:GetStringHeight()
        print(fontHeight)
    end
    if string.upper(text) == "!HEIGHT" then
        local winHeight = f:GetHeight()
        print(winHeight)
    end
    
    
end


f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("CHAT_MSG_SAY")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

