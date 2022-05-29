--Made by yaboi ScriptCat#6566 // @Keramis

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
    local screenx = memory.read_float(sx) local screeny = memory.read_float(sy) memory.free(sx) memory.free(sy)
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
    txtscale = 0.5,
    disablecolorlines = false,
    intcheck = true,
    name = false,
    name_sync = true,
    health = false
}

local function tableFin(colortbl, distance)
    for i = 1, #colortbl do if distance <= colortbl[i][2] then return {r = colortbl[i][3], g = colortbl[i][4], b = colortbl[i][5]} end end
    return {r = 255, g = 255, b = 255} --if out of range, return white ;)
end

menu.toggle_loop(menuroot, "ESP On All Players", {"catesp"}, "Enables color-proximity ESP on all players.", function ()
    local playerlist = players.list(false, true, true)
    for i = 1, #playerlist do
        local targetped = getPlayerPed(playerlist[i])
        local ppos = getEntityCoords(targetped)
        if ((not (players.is_in_interior(playerlist[i]) or ppos.z < -10)) and esp_settings.intcheck) or (not esp_settings.intcheck)then
            local mypos = getEntityCoords(getLocalPed())
            local playerHeadOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, 0, 0, 1.0)
            local vdist = SYSTEM.VDIST2(mypos.x, mypos.y, mypos.z, ppos.x, ppos.y, ppos.z)
            local col = tableFin(colorProximities, vdist)
            if not esp_settings.disablecolorlines then
                drawLine(mypos, ppos, col.r, col.g, col.b, 200)
            else
                drawLine(mypos, ppos, 255, 255, 255, 200)
            end
            if esp_settings.name then
                local screenName = worldToScreen(playerHeadOffset)
                if screenName.success then --dont want to draw names that are outside the screen, they will clump up at the top left.
                    if esp_settings.name_sync then
                        directx.draw_text(screenName.x, screenName.y - 0.02, GetPlayerName_pid(playerlist[i]), ALIGN_CENTRE, esp_settings.txtscale, col.r, col.g, col.b, 200)
                    else
                        directx.draw_text(screenName.x, screenName.y - 0.02, GetPlayerName_pid(playerlist[i]), ALIGN_CENTRE, esp_settings.txtscale, 255, 255, 255, 200)
                    end
                end
            end
            if esp_settings.health then
                local screenName = worldToScreen(playerHeadOffset)
                if screenName.success then --dont want to draw names that are outside the screen, they will clump up at the top left.
                    local health = ENTITY.GET_ENTITY_HEALTH(targetped)-100 local maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(targetped)-100
                    if esp_settings.name_sync then
                        directx.draw_text(screenName.x, screenName.y - 0.02*2, "(" .. health .. " / " .. maxhealth .. ")", ALIGN_CENTRE, esp_settings.txtscale, col.r, col.g, col.b, 200)
                    else
                        directx.draw_text(screenName.x, screenName.y - 0.02*2, "(" .. health .. " / " .. maxhealth .. ")", ALIGN_CENTRE, esp_settings.txtscale, 255, 255, 255, 200)
                    end
                end
            end
        end
    end
end)

local proximities = menu.list(menuroot, "Color Settings, Proximities", {"catprox"}, "Settings for the proximity colors.")

for i = 1, #colorProximities do
    menu.slider(proximities, colorProximities[i][1] .. " range", {"catesp " .. colorProximities[i][1]}, "Range for " .. colorProximities[i][1] .. " esp.", 1, 100000, (i*200), 50, function (value)
        colorProximities[i][2] = value*value
    end)
end

menu.toggle(proximities, "Underground/interior check", {"catinterior"}, "Doesn't ESP the player if they are in an interior or are underground.", function (toggle)
    esp_settings.intcheck = toggle
end, true)

menu.toggle(proximities, "Disable Colored Lines", {"catdisablecolorlines"}, "Disables the colored lines of the line ESP, making them all white. Has no effect on Name ESP color, though.", function (toggle)
    esp_settings.disablecolorlines = toggle
end)

menu.toggle(proximities, "Name ESP", {"catname"}, "This will draw the player's name above them, if enabled.", function (toggle)
    esp_settings.name = toggle
end)

menu.toggle(proximities, "Name ESP Syncs With Color", {"catespnamesync"}, "This will make the Name ESP have the same color as the line.", function (toggle)
    esp_settings.name_sync = toggle
end, true)

menu.toggle(proximities, "Health ESP", {"cathealth"}, "This will draw the player's health above, if enabled.", function (toggle)
    esp_settings.health = toggle
end)

menu.slider(proximities, "Scale of Text (/100)", {"catscaletext"}, "Scale of the text, divided by 100. For health and name esp.", 1, 500, 50, 10, function (value)
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
    menu.toggle_loop(playerRoot, "ESP On Player", {"catesp"}, "Enables ESP on this specific player. Uses color settings found in main script menu.", function ()
        local targetped = getPlayerPed(pid)
        local ppos = getEntityCoords(targetped)
        if ((not (players.is_in_interior(pid) or ppos.z < -10)) and esp_settings.intcheck) or (not esp_settings.intcheck)then
            local mypos = getEntityCoords(getLocalPed())
            local playerHeadOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, 0, 0, 1.0)
            local vdist = SYSTEM.VDIST2(mypos.x, mypos.y, mypos.z, ppos.x, ppos.y, ppos.z)
            local col = tableFin(colorProximities, vdist)
            if not esp_settings.disablecolorlines then
                drawLine(mypos, ppos, col.r, col.g, col.b, 200)
            else
                drawLine(mypos, ppos, 255, 255, 255, 200)
            end
            if esp_settings.name then
                local screenName = worldToScreen(playerHeadOffset)
                if screenName.success then --dont want to draw names that are outside the screen, they will clump up at the top left.
                    if esp_settings.name_sync then
                        directx.draw_text(screenName.x, screenName.y - 0.02, GetPlayerName_pid(pid), ALIGN_CENTRE, esp_settings.txtscale, col.r, col.g, col.b, 200)
                    else
                        directx.draw_text(screenName.x, screenName.y - 0.02, GetPlayerName_pid(pid), ALIGN_CENTRE, esp_settings.txtscale, 255, 255, 255, 200)
                    end
                end
            end
            if esp_settings.health then
                local screenName = worldToScreen(playerHeadOffset)
                if screenName.success then --dont want to draw names that are outside the screen, they will clump up at the top left.
                    local health = ENTITY.GET_ENTITY_HEALTH(targetped)-100 local maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(targetped)-100
                    if esp_settings.name_sync then
                        directx.draw_text(screenName.x, screenName.y - 0.02*2, "(" .. health .. " / " .. maxhealth .. ")", ALIGN_CENTRE, esp_settings.txtscale, col.r, col.g, col.b, 200)
                    else
                        directx.draw_text(screenName.x, screenName.y - 0.02*2, "(" .. health .. " / " .. maxhealth .. ")", ALIGN_CENTRE, esp_settings.txtscale, 255, 255, 255, 200)
                    end
                end
            end
        end
    end)
end

players.on_join(playerFunctions)
players.dispatch_on_join()