local DequeList = require("scripts/mod_loader/deque_list")

BoardClass = Board

BoardClass.MovePawnsFromTile = function(self, loc)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	Tests.AssertTypePoint(loc, "Argument #1")

	-- In case there are multiple pawns on the same tile
	local pawnStack = DequeList()
	local point = Point(-1, -1)

	while self:IsPawnSpace(loc) do
		local pawn = self:GetPawn(loc)
		pawnStack:pushLeft(pawn)
		pawn:SetSpace(point)
	end

	return pawnStack
end

BoardClass.RestorePawnsToTile = function(self, loc, pawnStack)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	Tests.AssertTypePoint(loc, "Argument #1")
	Tests.AssertEquals("table", type(pawnStack), "Argument #2")

	while not pawnStack:isEmpty() do
		local pawn = pawnStack:popLeft()
		pawn:SetSpace(loc)
	end
end

BoardClass.SetFire = function(self, loc, fire)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	Tests.AssertTypePoint(loc, "Argument #1")
	Tests.AssertEquals("boolean", type(fire), "Argument #2")

	local pawnStack = self:MovePawnsFromTile(loc)

	local dmg = SpaceDamage(loc)
	dmg.iFire = fire and EFFECT_CREATE or EFFECT_REMOVE
	self:DamageSpace(dmg)

	self:RestorePawnsToTile(loc, pawnStack)
end

BoardClass.GetLuaString = function(self)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	
	local size = self:GetSize()
	return string.format("Board [width = %s, height = %s]", size.x, size.y)
end
BoardClass.GetString = BoardClass.GetLuaString

BoardClass.IsMissionBoard = function(self)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	
	return self.isMission == true
end

BoardClass.IsTipImage = function(self)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	
	return self.isMission == nil
end

local function buildBoardWrapper(board)
	local metaBoardWrapper = setmetatable({}, {
		__index = function(inputTable, inputKey)
			if type(board[inputKey]) == "function" then
				inputTable[inputKey] = function(self, ...)
					return board[inputKey](board, ...)
				end

				return inputTable[inputKey]
			elseif board[inputKey] then
				return board[inputKey]
			end

			return nil
		end
	})

	metaBoardWrapper.Board = board
	metaBoardWrapper.GetUserdata = function(self)
		return self.Board
	end

	return setmetatable({}, { __index = metaBoardWrapper })
end

local function isGameBoard(board)
	return board:GetPawn(0) ~= nil and board:GetPawn(1) ~= nil and board:GetPawn(2) ~= nil
end

local function isTestMechBoard(board)
	return xor(board:GetPawn(0) ~= nil, board:GetPawn(1) ~= nil, board:GetPawn(2) ~= nil)
end

local cachedGameBoard = nil
local oldSetBoard = SetBoard
function SetBoard(board)
	if board == nil then
		cachedGameBoard = nil
		return oldSetBoard(board)
	else
		if isGameBoard(board) or isTestMechBoard(board) then
			if not cachedGameBoard then
				cachedGameBoard = buildBoardWrapper(board)
			end
			return oldSetBoard(cachedGameBoard)
		end
	end

	return oldSetBoard(buildBoardWrapper(board))
end

function GetBoard()
	if Board == nil then
		return nil
	else
		return Board:GetUserdata()
	end
end
