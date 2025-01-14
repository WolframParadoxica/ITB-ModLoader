local scripts = {
	"vector",
	"init",
	"global",
	"statistics",
	"ftldat",
	"version",
	"misc",
	"sandbox",
	"config",
	"hooks",
	"data",
	"text",
	"personalities",
	"personalities_csv",
	"assets",
	"animations",
	"achievement",
	"medals",
	"palette",
	"squad",
	"drops",
	"map",
	"mission",
	"skills",
	"savedata",
	"hotkey",
	"board",
	"pawn",
	"game",
	"localization",
	"compat",
	"deployment",
	"gameState",
	"tileset",
}

local rootpath = GetParentPath(...)
for i, filepath in ipairs(scripts) do
	require(rootpath..filepath)
end
