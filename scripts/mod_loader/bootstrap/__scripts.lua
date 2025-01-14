local scripts = {
	"security",
	"assert",
	"classes",
	"itb_io",
	"io",
	"utils",
	"event",
	"modApi",
	"constants",
	"binarySearch",
}

local rootpath = GetParentPath(...)
for i, filepath in ipairs(scripts) do
	require(rootpath..filepath)
end
