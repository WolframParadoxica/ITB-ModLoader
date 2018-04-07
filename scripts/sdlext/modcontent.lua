-- adds a "Mod Content" button to the main menu as wee as API for
-- adding items to the menu it opens


local bg0 = sdlext.surface("img/main_menus/bg0.png")
local bgRobot = sdlext.surface("img/main_menus/bg3.png")
local loading = sdlext.surface("img/main_menus/Loading_main.png")
local hangar = sdlext.surface("img/strategy/hangar_main.png")
local cursor = sdl.surface("resources/mods/ui/pointer-noshadow.png")
local menuFont = sdlext.font("fonts/JustinFont11Bold.ttf", 24)

modContent = {}
function sdlext.addModContent(text, func, tip)
	local obj = {caption = text, func = func, tip = tip}
	
	modContent[#modContent+1] = obj
	
	return obj
end

local isInMainMenu = false
function sdlext.isMainMenu()
	return isInMainMenu
end

local buttonModContent
local ui
local function createUi(screen)
	if ui ~= nil then return end
	
	ui = UiRoot():widthpx(screen:w()):heightpx(screen:h())
	
	buttonModContent = MainMenuButton("long")
		:pospx(0, screen:h() - 186)
		:caption("Mod Content")
		:addTo(ui)
	buttonModContent.visible = false

	buttonModContent.onclicked = function()
		sdlext.uiEventLoop(function(ui,quit)
			ui.onclicked = function()
				quit()
				return true
			end

			local frame = Ui()
				:width(0.4):height(0.8)
				:pos(0.3, 0.1)
				:caption("Mod content")
				:decorate({ DecoFrame(), DecoFrameCaption() })
				:addTo(ui)

			local scrollarea = UiScrollArea()
				:width(1):height(1)
				:padding(16)
				:decorate({ DecoSolid(deco.colors.buttoncolor) })
				:addTo(frame)
			
			local buttonHeight = 42
			local offset = 0
			for i = 1,#modContent do
				local obj = modContent[i]
				local buttongo = Ui()
					:pospx(0, offset)
					:width(1)
					:heightpx(buttonHeight)
					:caption(obj.caption)
					:settooltip(obj.tip)
					:decorate({ DecoButton(),DecoCaption() })
					:addTo(scrollarea)

				offset = offset + buttonHeight + 12
				
				if obj.disabled then buttongo.disabled = true end
				
				buttongo.onclicked = function()
					quit()
					obj.func()

					return true
				end
			end
		end)

		return true
	end
end


AUTO_HOOK_Mod_Content_Draw = sdl.drawHook(function(screen)
	isInMainMenu = bgRobot:wasDrawn() and bgRobot.x < screen:w() and not hangar:wasDrawn()
	isInHangar = hangar:wasDrawn()
	
	if sdlext.isMainMenu() then
		createUi(screen)

		if not buttonModContent.visible then
			buttonModContent.visible = true
			buttonModContent.animations.slideIn:start()
		end
		
		ui:draw(screen)
	elseif isInHangar then
		buttonModContent.visible = false
	end
	
	if not loading:wasDrawn() then
		screen:blit(cursor,nil,sdl.mouse.x(),sdl.mouse.y())
	end
end)

AUTO_HOOK_Mod_Content_Event = sdl.eventHook(function(event)
	if ui == nil or not sdlext.isMainMenu() then return false end
	
	return ui:event(event)
end)
