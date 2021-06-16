_G.Main_Menu_Elements_Size_Manager = _G.Main_Menu_Elements_Size_Manager or {}
Main_Menu_Elements_Size_Manager.started = false
Main_Menu_Elements_Size_Manager.settings = {}

Main_Menu_Elements_Size_Manager.path = ModPath
Main_Menu_Elements_Size_Manager.save_path = SavePath .. "Main_Menu_Elements_Size_Manager.txt"

--[[ function Main_Menu_Elements_Size_Manager:IsEnabled()
	return self.settings.enabled
end ]]

function Main_Menu_Elements_Size_Manager:DebugEnabled()
	return false
end

--[[ function Main_Menu_Elements_Size_Manager:Toggle_Enabled(enabled)
	if enabled == nil then 
		self.settings.enabled = not self.settings.enabled
	else
		self.settings.enabled = enabled
	end
	return self.settings.enabled
end ]]

function Main_Menu_Elements_Size_Manager:Load()
	local file = io.open(self.save_path,"r")
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

function Main_Menu_Elements_Size_Manager:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

--[[ Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Main_Menu_Elements_Size_Manager", function( loc )
	if file.DirectoryExists(Main_Menu_Elements_Size_Manager.path .. "loc/") then
		for _, filename in pairs(file.GetFiles(Main_Menu_Elements_Size_Manager.path .. "loc/")) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(Main_Menu_Elements_Size_Manager.path .. "loc/" .. filename)
				break
			end
		end
	end
	loc:load_localization_file(Main_Menu_Elements_Size_Manager.path .. "loc/english.json", false)
end) ]]
Hooks:Add("MenuManagerBuildCustomMenus", "Main_Menu_Elements_Size_Manager_MenuManagerBuildCustomMenus", function(menu_manager, nodes)
	local mainmenu = nodes.main
	if mainmenu == nil then
		return
	end
	
	for index, item in pairs(mainmenu._items) do
		for i, v in pairs(item._parameters) do
			if i == "font_size" then
				item._parameters.font_size = 24
			end
		end
	end
end)
--[[ Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_Main_Menu_Elements_Size_Manager", function(menu_manager)
	MenuCallbackHandler.Main_Menu_Elements_Size_ManagerChangedFocus = function(self, focus)
		if not focus then
			Main_Menu_Elements_Size_Manager:Save()
		end
	end

	MenuCallbackHandler.callback_Main_Menu_Elements_Size_Manager_close = function(self,item)
		Main_Menu_Elements_Size_Manager:Save()
	end
	
	Main_Menu_Elements_Size_Manager:Load()

--	MenuHelper:LoadFromJsonFile(Main_Menu_Elements_Size_Manager.path .. "menu/options.json", Main_Menu_Elements_Size_Manager, Main_Menu_Elements_Size_Manager.settings)
end) ]]