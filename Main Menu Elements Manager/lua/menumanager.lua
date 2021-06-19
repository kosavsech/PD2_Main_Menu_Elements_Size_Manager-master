_G.Main_Menu_Elements_Manager = _G.Main_Menu_Elements_Manager or {}
Main_Menu_Elements_Manager.path = ModPath
Main_Menu_Elements_Manager.save_path = SavePath .. "Main_Menu_Elements_Manager.txt"
Main_Menu_Elements_Manager.default_settings = {}
Main_Menu_Elements_Manager.elements = nil

function Main_Menu_Elements_Manager:DebugEnabled()
	return false
end

function deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Main_Menu_Elements_Manager:Load()
    self.settings = deep_copy(self.default_settings)
    local file = io.open(self.save_path, "r")
    if file then
        local data = file:read("*a")
        if data then
            local decoded_data = json.decode(data)
            if decoded_data then
                for key, value in pairs(self.settings) do
                    if decoded_data[key] ~= nil then
                        self.settings[key] = deep_copy(decoded_data[key])
                    end
                end
            end
        end
        file:close()
    end
end

function Main_Menu_Elements_Manager:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

local function HideElement(element)
	element._parameters.visible_callback = "hidden"
	element._visible_callback_list = {MenuCallbackHandler.hidden}
	element._visible_callback_name_list = {"hidden"}
end

function Main_Menu_Elements_Manager:IsElementValidForEditing(element)
	local function IsElementVisible(visible_callback_name_list)
		if visible_callback_name_list == nil or table.size(visible_callback_name_list) < 1 then
			return true
		end
	
		local MenuCallbackHandler = _G.MenuCallbackHandler
		for __, function_name in ipairs(visible_callback_name_list) do
			local func = MenuCallbackHandler[function_name]
			if func and not func(MenuCallbackHandler) then
				return false
			end
		end
		return true
	end
	local whitelist = {
		["crimenet"] = true,
		["crimenet_offline"] = true,
		["fast_net_core"] = true,
		["story_missions"] = true,
		["inventory"] = true,
		["achievements"] = true,
		["wolfhud_create_empty_lobby_btn"] = true,
		["steam_inventory"] = true,
		["fbi_files"] = true,
		["gamehub"] = true,
		["movie_theater"] = true,
		["divider_test2"] = true,
		["options"] = true,
		["divider_infamy"] = true,
		["quit"] = true,
	}
	
	if whitelist[element._parameters.name] and IsElementVisible(element._visible_callback_name_list) then
		return true
	end
end

local function GetElementsValues(element, req_text_id, req_font_size, req_pos_value, visibility)
	Main_Menu_Elements_Manager:Load()
	if Main_Menu_Elements_Manager.default_settings[tostring(element._parameters.name)] == nil then
		Main_Menu_Elements_Manager.default_settings[tostring(element._parameters.name)] = {}
		Main_Menu_Elements_Manager.settings[tostring(element._parameters.name)] = {}
	end
	if req_text_id then
		Main_Menu_Elements_Manager.default_settings[tostring(element._parameters.name)].loc_name = managers.localization:text(tostring(element._parameters.text_id))
		return Main_Menu_Elements_Manager.settings[tostring(element._parameters.name)].loc_name or managers.localization:text(tostring(element._parameters.text_id))
	elseif req_font_size then
		Main_Menu_Elements_Manager.default_settings[tostring(element._parameters.name)].font_size = element._parameters.font_size or 24
		return Main_Menu_Elements_Manager.settings[tostring(element._parameters.name)].font_size or element._parameters.font_size or 24
	elseif req_pos_value then
		Main_Menu_Elements_Manager.default_settings[tostring(element._parameters.name)].pos_value = req_pos_value
		return Main_Menu_Elements_Manager.settings[tostring(element._parameters.name)].pos_value or req_pos_value
	elseif visibility then
		Main_Menu_Elements_Manager.default_settings[tostring(element._parameters.name)].visibility_toggle = true
		return Main_Menu_Elements_Manager.settings[tostring(element._parameters.name)].visibility_toggle or true
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Main_Menu_Elements_Manager", function( loc )
	if file.DirectoryExists(Main_Menu_Elements_Manager.path .. "loc/") then
		for _, filename in pairs(file.GetFiles(Main_Menu_Elements_Manager.path .. "loc/")) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(Main_Menu_Elements_Manager.path .. "loc/" .. filename)
				break
			end
		end
	end
	loc:load_localization_file(Main_Menu_Elements_Manager.path .. "loc/english.json", false)
end)


Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_Main_Menu_Elements_Manager", function(menu_manager)
	MenuCallbackHandler.visibility_change_callback = function(self,item)
		local element = string.gsub(item:name(), "_visibility_toggle", "")
		Main_Menu_Elements_Manager.settings[tostring(element)].visibility_toggle = Utils:ToggleItemToBoolean(item)
	end

	MenuCallbackHandler.loc_name_change_callback = function(self,item)
		local element = string.gsub(item:name(), "_loc_name", "")
		Main_Menu_Elements_Manager.settings[tostring(element)].loc_name = item:value()
	end

	MenuCallbackHandler.pos_value_change_callback = function(self,item)
		local element = string.gsub(item:name(), "_pos_value", "")
		Main_Menu_Elements_Manager.settings[tostring(element)].pos_value = tonumber(item:value())
	end

	MenuCallbackHandler.font_size_change_callback = function(self,item)
		local element = string.gsub(item:name(), "_font_size", "")
		Main_Menu_Elements_Manager.settings[tostring(element)].font_size = tonumber(item:value())
	end
	

	MenuCallbackHandler.Main_Menu_Elements_Manager_ChangedFocus = function(self, focus)
		if not focus then
			Main_Menu_Elements_Manager:Save()
		end
	end

	MenuCallbackHandler.Main_Menu_Elements_Manager_back = function(self,item)
		Main_Menu_Elements_Manager:Save()
	end
	
	Main_Menu_Elements_Manager:Load()

	Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_Main_Menu_Elements_Manager_mod_main_menu", function( menu_manager, nodes)
		MenuHelper:NewMenu( "Main_Menu_Elements_Manager_mod_main_menu" )
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "Base_BuildCustomMenus_Json_Main_Menu_Elements_Manager_mod_main_menu", function(menu_manager, nodes)
		local mainmenu = nodes.main
		if mainmenu == nil then
			return
		end
		Main_Menu_Elements_Manager.elements = {}
		for index, element in ipairs(mainmenu._items) do
			if Main_Menu_Elements_Manager:IsElementValidForEditing(element) then
				table.insert( Main_Menu_Elements_Manager.elements, index, element )
				if Main_Menu_Elements_Manager:DebugEnabled() then
					log("DEBUG .elements add item: " .. tostring(element._parameters.name) .. " ".. index)
				end
			end
		end
		Hooks:Call( "SpecialMenuManagerPopulateCustomMenus", nodes )

		for index, item in pairs(mainmenu._items) do
			if Main_Menu_Elements_Manager:IsElementValidForEditing(item) then
				if Main_Menu_Elements_Manager.settings[tostring(item._parameters.name)] ~= nil then
					table.remove( mainmenu._items, index )
					table.insert( mainmenu._items, Main_Menu_Elements_Manager.settings[tostring(item._parameters.name)].pos_value, item )

					local localized_strings = {}
					localized_strings[tostring(item._parameters.text_id)] = Main_Menu_Elements_Manager.settings[tostring(item._parameters.name)].loc_name
					managers.localization:add_localized_strings(localized_strings)

					item._parameters.font_size = Main_Menu_Elements_Manager.settings[tostring(item._parameters.name)].font_size

					if Main_Menu_Elements_Manager.settings[tostring(item._parameters.name)].visibility_toggle == false then
						HideElement(item)
					end
				end
			end
		end
		local parent_menu = "blt_options"
		local menu_id = "Main_Menu_Elements_Manager_mod_main_menu"
		local menu_name = "Main_Menu_Elements_Manager_mod_main_menu_title"
		local menu_desc = "Main_Menu_Elements_Manager_mod_main_menu_desc"

		local data = {
			focus_changed_callback = "Main_Menu_Elements_Manager_ChangedFocus",
			back_callback = "Main_Menu_Elements_Manager_back",
			area_bg = nil,
		}
		nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

		MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )
	end)
end)
Hooks:RegisterHook("SpecialMenuManagerPopulateCustomMenus")
Hooks:Add("SpecialMenuManagerPopulateCustomMenus", "SpecialMenuManagerPopulateCustomMenus_Callback_Main_Menu_Elements_Manager_mod_main_menu", function(menu_manager)
	MenuCallbackHandler.reset_callback = function(self, item)
		for __, node in ipairs(item._parameters.gui_node.row_items) do
			local item_name, item_index_value = string.match(tostring(node.item._parameters.name), "(.+)[*_*]+((.+)[*_*]+(.+))")
			if Main_Menu_Elements_Manager.default_settings[item_name] ~= nil then
				for index, value in pairs(Main_Menu_Elements_Manager.default_settings[item_name]) do
					if index == item_index_value then
						if Main_Menu_Elements_Manager:DebugEnabled() then
							log("DEBUG item: " .. item_name .. " ".. index .. " "..  item_index_value .. " value: " .. tostring(value))
							managers.mission._fading_debug_output:script().log("DEBUG item: " .. item_name .. " ".. index .. " "..  item_index_value .. " value: " .. tostring(value), Color.green)
						end
						Main_Menu_Elements_Manager.settings[item_name][index] = value
						if node.item.set_value then
							if node.item._type == "toggle" then
								node.item:set_value(value and "on" or "off")
							else
								node.item:set_value(value)
							end
							node.item:trigger()
							managers.viewport:resolution_changed()
						end
					end
				end
			end
		end
	end
end)
Hooks:Add("SpecialMenuManagerPopulateCustomMenus", "Base_PopulateCustomMenus_Json_Main_Menu_Elements_Manager_mod_main_menu", function(nodes)
	local prior = 666
	MenuHelper:AddButton({
		id = "Main_Menu_Elements_Manager_mod_reset",
		title = "Main_Menu_Elements_Manager_mod_reset_title",
		desc = "Main_Menu_Elements_Manager_mod_reset_desc",
		callback = "reset_callback",
		menu_id = "Main_Menu_Elements_Manager_mod_main_menu",
		priority = 668
	})
	MenuHelper:AddDivider({
		id = "Main_Menu_Elements_Manager_mod_divider1",
		size = 28,
		menu_id = "Main_Menu_Elements_Manager_mod_main_menu",
		priority = 667
	})
	for index, element in pairs(Main_Menu_Elements_Manager.elements) do
		MenuHelper:AddToggle({
			id = tostring(element._parameters.name) .. "_visibility_toggle",
			title = tostring(element._parameters.name) .. "_visibility_toggle_title",
			desc = tostring(element._parameters.name) .. "_visibility_toggle_desc",
			callback = "visibility_change_callback",
			priority = prior,
			value = GetElementsValues(element, nil, nil, nil, true),
			menu_id = "Main_Menu_Elements_Manager_mod_main_menu"
		})
		prior = prior - 1
		MenuHelper:AddInput({
			id = tostring(element._parameters.name) .. "_loc_name",
			title = "Main_Menu_Elements_Manager_loc_name_title",
			desc = "Main_Menu_Elements_Manager_loc_name_desc",
			callback = "loc_name_change_callback",
			priority = prior,
			value = GetElementsValues(element, true, nil, nil, nil),
			menu_id = "Main_Menu_Elements_Manager_mod_main_menu"
		})
		prior = prior - 1
		MenuHelper:AddInput({
			id = tostring(element._parameters.name) .. "_pos_value",
			title = "Main_Menu_Elements_Manager_pos_value_title",
			desc = "Main_Menu_Elements_Manager_pos_value_desc",
			callback = "pos_value_change_callback",
			priority = prior,
			value = GetElementsValues(element, nil, nil, index, nil),
			menu_id = "Main_Menu_Elements_Manager_mod_main_menu"
		})
		prior = prior - 1
		MenuHelper:AddInput({
			id = tostring(element._parameters.name) .. "_font_size",
			title = "Main_Menu_Elements_Manager_font_size_title",
			desc = "Main_Menu_Elements_Manager_font_size_desc",
			callback = "font_size_change_callback",
			priority = prior,
			value = GetElementsValues(element, nil, true, nil, nil),
			menu_id = "Main_Menu_Elements_Manager_mod_main_menu"
		})
		prior = prior - 1
		MenuHelper:AddDivider({
			id = "Main_Menu_Elements_Manager_mod_divider",
			size = 28,
			menu_id = "Main_Menu_Elements_Manager_mod_main_menu",
			priority = prior
		})
		prior = prior - 1
	end
end)