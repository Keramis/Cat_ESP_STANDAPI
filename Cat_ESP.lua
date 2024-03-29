--Made by yaboi kryptcat // @Keramis

util.require_natives(1651208000)
util.keep_running()
--just some ease-of-use stuff for me ;)
local wait = util.yield()
local function getLocalPed()
    return PLAYER.PLAYER_PED_ID()
end
local getEntityCoords = ENTITY.GET_ENTITY_COORDS
local getPlayerPed = PLAYER.GET_PLAYER_PED
local menuroot = menu.my_root()

function GetPlayerName_ped(ped)
    local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(playerID)
    return playerName
end
function GetPlayerName_pid(pid)
    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(pid)
    return playerName
end

local function drawLine(c1, c2, r, g, b, a)
    GRAPHICS.DRAW_LINE(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, r, g, b, a)
end

local function worldToScreen(coords)
    local sx = memory.alloc()
    local sy = memory.alloc()
    local success = GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coords.x, coords.y, coords.z, sx, sy)
    local screenx = memory.read_float(sx) local screeny = memory.read_float(sy) --memory.free(sx) memory.free(sy)
    return {x = screenx, y = screeny, success = success}
end

local whiteColor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}

local colors = {
    red = {255, 0, 0},
    orange = {255, 127, 0},
    yellow = {255, 255, 0},
    green = {0, 255, 0},
    blue = {0, 0, 255},
    purple = {148, 0, 211}
}

local colorProximities = {
    {"Red", 200*200, 255, 0, 0},
    {"Orange", 400*400, 255, 127, 0},
    {"Yellow", 600*600, 255, 255, 0},
    {"Green", 800*800, 0, 255, 0},
    {"Blue", 1000*1000, 0, 0, 255},
    {"Purple", 1200*1200, 148, 0, 211},
}

local esp_settings = {
    line_esp = true,
    stand_lines = false,
    box_esp = false,
    txtscale = 0.5,
    disablecolorlines = false,
    intcheck = true,
    name = false,
    text_sync = true,
    health = false
}

local function drawESPText(coord, Yoffset, text, scale, color)
    directx.draw_text(coord.x, coord.y + Yoffset, text, ALIGN_CENTRE, scale, color.r, color.g, color.b, 1)
end

local function tableFin(colortbl, distance, standCompatible)
    if not standCompatible then
        for i = 1, #colortbl do if distance <= colortbl[i][2] then return {r = colortbl[i][3], g = colortbl[i][4], b = colortbl[i][5], a = 255} end end
        return {r = 255, g = 255, b = 255, a = 255} --if out of range, return white ;)
    else
        for i = 1, #colortbl do if distance <= colortbl[i][2] then return {r = colortbl[i][3]/255, g = colortbl[i][4]/255, b = colortbl[i][5]/255, a = 1.0} end end
        return {r = 1.0, g = 1.0, b = 1.0, a = 1.0} --if out of range, return white ;)
    end
end

local function nativeDrawLine(x1, y1, z1, x2, y2, z2, r, g, b, a)
    GRAPHICS.DRAW_LINE(x1, y1, z1, x2, y2, z2, r, g, b, a)
end

local function boxESPOnPlayer(pid, horizontalOffset, color)
    --[[mission: Box ESP
        Get Head Coordinates, with vertical offset to account for center-of-head
        Get Tallness of player (1.94m)
        Using a horizontal offset, get the top corners.
        Using the tallness, get the bottom corners.
        Draw the lines!
    ]]
    local targetped = getPlayerPed(pid)
    local topOfHead = PED.GET_PED_BONE_COORDS(targetped, 31086, 0, 0, 0); topOfHead.z = topOfHead.z + 0.30 --[[SKEL_Head || 31086]] --[[0.30 vertical offset for head]]
    local bottomOfFeet = {z = topOfHead.z - 1.94}
    local rightCorner = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, horizontalOffset, 0, 0); rightCorner.z = topOfHead.z
    local leftCorner = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, -horizontalOffset, 0, 0); leftCorner.z = topOfHead.z
    local bRightCorner = rightCorner; bRightCorner.z = topOfHead.z - 1.94
    local bLeftCorner = leftCorner; bLeftCorner.z = topOfHead.z - 1.94

    nativeDrawLine(rightCorner.x, rightCorner.y, topOfHead.z, leftCorner.x, leftCorner.y, topOfHead.z, color.r, color.g, color.g, color.a) --top line
    nativeDrawLine(rightCorner.x, rightCorner.y, topOfHead.z, bRightCorner.x, bRightCorner.y, bottomOfFeet.z, color.r, color.g, color.g, color.a) --right line
    nativeDrawLine(leftCorner.x, leftCorner.y, topOfHead.z, bLeftCorner.x, bLeftCorner.y, bottomOfFeet.z, color.r, color.g, color.g, color.a) --left line
    nativeDrawLine(bRightCorner.x, bRightCorner.y, bottomOfFeet.z, bLeftCorner.x, bLeftCorner.y, bottomOfFeet.z, color.r, color.g, color.g, color.a) --bottom line

    --local tt = worldToScreen(rightCorner); directx.draw_line(0.5, 1.0, tt.x, tt.y, whiteColor)
end

local function espOnPlayer(pid, intcheck, disablecolorlines, namesync, lineesp, boxesp, nameesp, healthesp, txtscale, standESP)
    local targetped = getPlayerPed(pid)
    local ppos = getEntityCoords(targetped)
    if (((not players.is_in_interior(pid)) or (ppos.z < -10)) and intcheck) or (not intcheck)then --checking for interior, underground

        --coordinate stuff
        local mypos = getEntityCoords(getLocalPed())
        local playerHeadOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, 0, 0, 1.0)
        local centerPlayer = getEntityCoords(targetped)
        local vdist = SYSTEM.VDIST2(mypos.x, mypos.y, mypos.z, ppos.x, ppos.y, ppos.z)

        --color settings
        local colLineNative
        local colText
        if not disablecolorlines then colLineNative = tableFin(colorProximities, vdist, false) else colLineNative = {r = 255, g = 255, b = 255, a = 255} end --setting for if lines are colored
        if namesync then colText = tableFin(colorProximities, vdist, true) else colText = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} end --setting for if text should be colored

        --head offset for all texts
        local screenName = worldToScreen(playerHeadOffset)

        --line ESP
        if lineesp then
            local cent = worldToScreen(centerPlayer)
            if cent.success and standESP then --if they're on the screen, we use the directX function, since it's faster and goes thru buildings.
                if CAM.GET_CAM_VIEW_MODE_FOR_CONTEXT(CAM._GET_CAM_ACTIVE_VIEW_MODE_CONTEXT()) ~= 4 then --check if in first person
                    --thank you aaron!
                    local localcent = worldToScreen(mypos)
                    local colLineStand
                    if not disablecolorlines then colLineStand = tableFin(colorProximities, vdist, true) else colLineStand = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} end
                    directx.draw_line(localcent.x, localcent.y, cent.x, cent.y, colLineStand)
                else
                    local colLineStand
                    if not disablecolorlines then colLineStand = tableFin(colorProximities, vdist, true) else colLineStand = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} end
                    directx.draw_line(0.5, 1.0, cent.x, cent.y, colLineStand)
                end
            else
                drawLine(mypos, ppos, colLineNative.r, colLineNative.g, colLineNative.b, colLineNative.a) --else we use the native func (behnid us)
            end
        end
        --box ESP
        if boxesp then
            boxESPOnPlayer(pid, 0.5, colLineNative)
        end
        --text ESP
        if screenName.success then --check if it should be drawn, since we don't want to draw things that are out of the screen.
            --name ESP
            if nameesp then
                drawESPText(screenName, -0.02, GetPlayerName_pid(pid), txtscale, colText)
            end

            --health ESP
            if healthesp then
                local health = ENTITY.GET_ENTITY_HEALTH(targetped)-100 local maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(targetped)-100
                drawESPText(screenName, -0.02*2, "(" .. health .. " / " .. maxhealth .. ")", txtscale, colText)
            end
        end
    end
end

menu.toggle_loop(menuroot, "ESP On All Players", {"catesp"}, "Enables color-proximity ESP on all players.", function ()
    local playerlist = players.list(false, true, true)
    for i = 1, #playerlist do
        espOnPlayer(playerlist[i], esp_settings.intcheck, esp_settings.disablecolorlines,
        esp_settings.text_sync, esp_settings.line_esp, esp_settings.box_esp, esp_settings.name, esp_settings.health,
        esp_settings.txtscale, esp_settings.stand_lines)
    end
end)




--settings


local proximities = menu.list(menuroot, "Color Settings, Proximities", {"catprox"}, "Settings for the proximity colors.")
menu.divider(proximities, "Color Proximities")

for i = 1, #colorProximities do
    menu.slider(proximities, colorProximities[i][1] .. " range", {"catesp " .. colorProximities[i][1]}, "Range for " .. colorProximities[i][1] .. " esp.", 1, 100000, (i*200), 50, function (value)
        colorProximities[i][2] = value*value
    end)
end


local espenables = menu.list(menuroot, "ESP Settings/Enabled", {"catenabled"}, "Settings for which ESP is enabled, settings.")

menu.toggle(espenables, "Underground/interior check", {"catinterior"}, "Doesn't ESP the player if they are in an interior or are underground.", function (toggle)
    esp_settings.intcheck = toggle
end, true)

menu.toggle(espenables, "Line ESP", {"catlineesp"}, "Enables Line ESP.", function (toggle)
    esp_settings.line_esp = toggle
end, true)

menu.toggle(espenables, "Stand Line ESP", {"catstandesp"}, "Line ESP will now use Stand's draw function for lines, which goes through buildings.", function (toggle)
    esp_settings.stand_lines = toggle
end)

menu.toggle(espenables, "Box ESP", {"catboxesp"}, "Box ESP, with rotation.", function (toggle)
    esp_settings.box_esp = toggle
end)

menu.toggle(espenables, "Disable Colored Lines", {"catdisablecolorlines"}, "Disables the colored lines of the line ESP, making them all white. Has no effect on Name ESP color, though.", function (toggle)
    esp_settings.disablecolorlines = toggle
end)

menu.toggle(espenables, "Name ESP", {"catname"}, "This will draw the player's name above them, if enabled.", function (toggle)
    esp_settings.name = toggle
end)

menu.toggle(espenables, "Text ESP Syncs With Color", {"catespnamesync"}, "This will make the Name ESP have the same color as the line.", function (toggle)
    esp_settings.text_sync = toggle
end, true)

menu.toggle(espenables, "Health ESP", {"cathealth"}, "This will draw the player's health above, if enabled.", function (toggle)
    esp_settings.health = toggle
end)

menu.slider(espenables, "Scale of Text (/100)", {"catscaletext"}, "Scale of the text, divided by 100. For health and name esp.", 1, 500, 50, 10, function (value)
    esp_settings.txtscale = value/100
end)

--[[players.list looks like this:
playersList = {
    1 = pid1
    2 = pid2
    etc.
}]]

local function playerFunctions(pid)
    local playerRoot = menu.player_root(pid)
    menu.divider(playerRoot, "Cat_ESP.lua")
    menu.toggle_loop(playerRoot, "ESP On Player", {"catesp"}, "Enables ESP on this specific player. Uses color settings found in main script menu.", function ()
        espOnPlayer(pid, false, esp_settings.disablecolorlines,
        esp_settings.text_sync, esp_settings.line_esp, esp_settings.box_esp, esp_settings.name, esp_settings.health,
        esp_settings.txtscale, esp_settings.stand_lines)
    end)
end

players.on_join(playerFunctions)
players.dispatch_on_join()
