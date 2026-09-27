local BASE_URL = "https://raw.githubusercontent.com/dittod4rk/Slayer-2/refs/heads/main/scr/"

local function loadModule(moduleName)
	local url = BASE_URL .. moduleName .. ".lua"

	print("[Loader] Loading:", moduleName)
	print("[Loader] URL:", url)

	local success, source = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		error(
			"[Loader] Failed to download " ..
			moduleName ..
			".lua:\n" ..
			tostring(source)
		)
	end

	if type(source) ~= "string" or source == "" then
		error(
			"[Loader] Empty response from " ..
			moduleName ..
			".lua"
		)
	end

	-- GitHub returned a 404 instead of Lua
	if source:find("404: Not Found", 1, true)
		or source:match("^404") then

		error(
			"[Loader] 404 - File not found:\n" ..
			url
		)
	end

	local compiled, compileError =
		loadstring(source)

	if not compiled then
		error(
			"[Loader] Failed to compile " ..
			moduleName ..
			".lua:\n" ..
			tostring(compileError)
		)
	end

	local executed, result =
		pcall(compiled)

	if not executed then
		error(
			"[Loader] Error while running " ..
			moduleName ..
			".lua:\n" ..
			tostring(result)
		)
	end

	if type(result) ~= "table" then
		error(
			"[Loader] " ..
			moduleName ..
			".lua must return a table."
		)
	end

	print("[Loader] Loaded:", moduleName)

	return result
end


local UI = loadModule("UI")
local Souls = loadModule("Souls")
local Teleports = loadModule("Teleports")
local BossFarm = loadModule("BossFarm")
