if not isfolder("SkidWare") then
	makefolder("SkidWare")
end
local IsLocal = isfile("SkidWare/Installed") and (readfile("SkidWare/Installed") == "true")

local function Get(name: string)
	
end

local function Load(name: string)
	if IsLocal then
		return loadstring(readfile("SkidWare/" .. name))
	else
		return Get("SkidWare/" .. name)
	end
end