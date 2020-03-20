local rootpath = GetParentPath(...)

local testsuite = Tests.Testsuite()
function testsuite:RunAllTests(testEnumeratorFn)
	self.__index.RunAllTests(self, "Root Testsuite", testEnumeratorFn)
end

testsuite.pawn = require(rootpath.."pawn")
testsuite.sandbox = require(rootpath.."sandbox")
testsuite.cutil = require(rootpath.."cutil/main")

--[[
	Usage, in console while in a mission:
			Testsuites:RunAllTests()
		or:
			Testsuites.name_of_testsuite:RunAllTests()
--]]

Testsuites = testsuite
