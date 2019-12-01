
local PilotPersonality = nil
function CreatePilotPersonality(label, name)
	-- PilotPersonality is local to personality.lua
	-- We can't access it directly, so we have to grab it via
	-- the metatable of one of the existing PilotPersonality instances.
	-- 'Artificial' happens to be the most generic one.
	PilotPersonality = PilotPersonality or getmetatable(Personality["Artificial"])
	local t = PilotPersonality:new()

	-- Name of the pilot, leave nil for random name
	t.Name = name
	-- Pilot label, used in debug messages
	t.Label = label or "NULL"

	return t
end

function CreatePilot(data)
	_G[data.Id] = Pilot:new(data)

	-- Make sure we don't create duplicates if the PilotList
	-- already contains entry for this pilot
	if data.Rarity ~= 0 and not list_contains(PilotList, data.Id) then
		PilotList[#PilotList + 1] = data.Id
	end
end

function IsTestMechScenario()
	if not Game then return false end

	local p0 = Game:GetPawn(0)
	local p1 = Game:GetPawn(1)
	local p2 = Game:GetPawn(2)

	-- In test mech scenario, only one of the three
	-- player mechs will not be nil.
	return (    p0 and not p1 and not p2) or
	       (not p0 and     p1 and not p2) or
	       (not p0 and not p1 and     p2)
end

--[[
	Returns the table instance of the current mission. Returns nil when not in a mission.
--]]
function GetCurrentMission()
	if IsTestMechScenario() then
		return Mission_Test
	end

	return modApi.current_mission
end

function list_indexof(list, value)
	for k, v in ipairs(list) do
		if value == v then
			return k
		end
	end
	return nil
end

-- Returns true if tables are equal, false otherwise
function compare_tables(tbl1, tbl2)
	local r = true
	for k, v in pairs(tbl1) do
		if type(v) == "table" then
			if not compare_tables(tbl1[k], tbl2[k]) then
				return false
			end
		elseif type(v) == "userdata" then
			-- can't compare userdata, ignore
		else
			if tbl1[k] ~= tbl2[k] then
				return false
			end
		end
	end

	return true
end

Emitter_Blank = Emitter:new({
    timer = 0,
    lifespan = 0,
    max_particles = 0
})


---------------------------------------------------------------
-- Screenpoint to tile conversion

GetUiScale = function() return 1 end

--[[
	Returns currently highlighted board tile, or nil.
--]]
function mouseTile()
	-- Use custom table instead of the existing Point class, since Point
	-- can only hold integer values and automatically rounds them.
	return screenPointToTile({ x = sdl.mouse.x(), y = sdl.mouse.y() })
end

function getScreenRefs(screen, scale)
	scale = scale or GetBoardScale()
	local uiScale = GetUiScale()

	local tw = 28 * uiScale
	local th = 21 * uiScale

	-- Top corner of the (0, 0) tile
	local tile00 = {
		x = screen:w() / 2,
		y = screen:h() / 2 - 8 * th * scale
	}

	if scale == 2 then
		tile00.y = tile00.y + 5 * scale * uiScale + 0.5
	end

	local lineX = function(x) return x * th/tw end
	local lineY = function(x) return -lineX(x) end

	return tile00, lineX, lineY, tw, th
end

local function isPointAboveLine(point, lineFn)
	return point.y >= lineFn(point.x)
end

local function tileContains(tilex, tiley, tilew, tileh, point)
	local np = {
		x = point.x - tilew * (tilex - tiley),
		y = point.y - tileh * (tilex + tiley)
	}
	return isPointAboveLine(np, lineX)
		and isPointAboveLine(np, lineY)
end

--[[
	Returns a board tile at the specified point on the screen, or nil.
--]]
function screenPointToTile(screenPoint)
	if not Board then return nil end

	local screen = sdl.screen()
	local scale = GetBoardScale()
	local uiScale = GetUiScale()

	local tile00, lineX, lineY, tw, th = getScreenRefs(screen, scale)

	-- Change screenPoint to be relative to the (0, 0) tile
	-- and move to unscaled space.
	local relPoint = {}
	relPoint.x = (screenPoint.x - tile00.x) / scale
	relPoint.y = (screenPoint.y - tile00.y) / scale

	-- Start at the end of the board and move backwards.
	-- That way we only need to check 2 lines instead of 4 on each tile.
	-- The tradeoff is that we need to check an additional row and column
	-- of tiles outside of the board.
	local bsize = Board:GetSize()
	for tileY = bsize.y, 0, -1 do
		for tileX = bsize.x, 0, -1 do
			if tileContains(tileX, tileY, tw, th, relPoint) then
				if tileY == bsize.y or tileX == bsize.x then
					-- outside of the board
					return nil
				end
				
				return Point(tileX, tileY)
			end
		end
	end

	return nil
end

