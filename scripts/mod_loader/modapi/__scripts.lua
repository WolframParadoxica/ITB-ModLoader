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
	"localization",
	"compat",
	"deployment",
	"gameState",
}

local rootpath = GetParentPath(...)
for i, filepath in ipairs(scripts) do
	require(rootpath..filepath)
end
