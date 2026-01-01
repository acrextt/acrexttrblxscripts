
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local acrexttConfigurationManager = {}
local configurationTemplate = {
	version = "1.0",
	keybinds = {
		openHubInput = Enum.KeyCode.Insert,
		aimbotKey = "MouseButton2",
		flyKey = Enum.KeyCode.F
	},
	settings = {
		walkSpeed = 16,
		jumpPower = 50,
		jumpHeight = 7.2,
		infiniteJump = false,
		noClip = false,
		AimbotEnabled = false,
		AimbotFOV = 100,
		AimbotSmoothness = 0.12,
		aimbotPart = "Head",
		AimbotPredictionStrength = 0.5,
		IgnoreFriends = false,
		IgnoreTeam = true,
		EnemiesOnly = false,
		boxESP = false,
		tracers = false,
		nameTags = true,
		healthBar = true,
		fullBright = false,
		antiAFK = false,
		flyEnabled = false,
		flySpeed = 50,
		noclipKey = Enum.KeyCode.N
	}
}
local maxConfigurations = 3

local function getConfigKey()
	return "acrextt_configuration_2026_" .. tostring(Player.UserId)
end

local function getConfigFileName(configName : string)
	return getConfigKey() .. "_" .. configName .. ".json"
end

local function saveConfigToFile(configName : string, data : any) : boolean
	if writefile then
		local fileName = getConfigFileName(configName)
		writefile(fileName, HttpService:JSONEncode(data))
		return true
	end
	return false
end

local function loadConfigFromFile(configName : string)
	if readfile and isfile then
		local fileName = getConfigFileName(configName)
		if isfile(fileName) then
			local fileData = readfile(fileName)
			return HttpService:JSONDecode(fileData)
		end
	end
	return nil
end

local function deleteConfigFile(configName : string) : boolean
	if delfile and isfile then
		local fileName = getConfigFileName(configName)
		if isfile(fileName) then
			delfile(fileName)
			return true
		end
	end
	return false
end

local function listConfigFiles()
	local configs = {}
	if listfiles then
		local files = listfiles("")
		local prefix = getConfigKey() .. "_"
		for _, file in ipairs(files) do
			if string.find(file, prefix) then
				local configName = string.gsub(file, prefix, "")
				configName = string.gsub(configName, "%.json$", "")
				table.insert(configs, configName)
			end
		end
	end
	return configs
end

local function createDefaultConfig(configName : string)
	local newConfig = {
		name = configName,
		createdAt = os.time(),
		lastModified = os.time(),
		data = configurationTemplate
	}
	return newConfig
end

function acrexttConfigurationManager:getConfiguration(configurationName : string) : any
	if not configurationName then
		warn(`Can't find configuration without name.`)
		return nil
	end

	local loadedConfig = loadConfigFromFile(configurationName)
	if loadedConfig then
		return loadedConfig
	end

	return createDefaultConfig(configurationName)
end

function acrexttConfigurationManager:loadConfiguration(specificConfiguration : string) : any
	if not specificConfiguration then
		warn(`Specific configuration not given returning default configuration.`)
		local defaultConfig = createDefaultConfig("default")
		return defaultConfig.data
	end

	local loadedConfig = loadConfigFromFile(specificConfiguration)
	if loadedConfig then
		return loadedConfig.data
	end

	local newConfig = createDefaultConfig(specificConfiguration)
	saveConfigToFile(specificConfiguration, newConfig)
	return newConfig.data
end

function acrexttConfigurationManager:loadConfigurations() : any
	local allConfigs = {}
	local configNames = listConfigFiles()

	for _, configName in ipairs(configNames) do
		local config = loadConfigFromFile(configName)
		if config then
			table.insert(allConfigs, config)
		end
	end

	if #allConfigs == 0 then
		local defaultConfig = createDefaultConfig("default")
		saveConfigToFile("default", defaultConfig)
		table.insert(allConfigs, defaultConfig)
	end

	return allConfigs
end

function acrexttConfigurationManager:resetConfiguration(specificConfiguration : string)
	if not specificConfiguration then
		warn(`Can't reset configuration without specificConfiguration.`)
		return false
	end

	local defaultConfig = createDefaultConfig(specificConfiguration)
	return saveConfigToFile(specificConfiguration, defaultConfig)
end

function acrexttConfigurationManager:saveConfiguration(configuration : any) : any
	if not configuration then
		warn(`Can't save configuration is nil?`)
		return false
	end

	local configToSave = {
		name = configuration.name or "default",
		createdAt = configuration.createdAt or os.time(),
		lastModified = os.time(),
		data = configuration.data or configuration
	}

	local existingConfigs = listConfigFiles()
	if #existingConfigs >= maxConfigurations and not table.find(existingConfigs, configToSave.name) then
		warn(`Maximum configurations (${maxConfigurations}) reached. Delete one before saving.`)
		return false
	end

	return saveConfigToFile(configToSave.name, configToSave)
end

function acrexttConfigurationManager:saveConfigurations(configurations : any)
	if not configurations then
		warn(`No configurations provided to save.`)
		return false
	end

	local success = true
	for _, config in ipairs(configurations) do
		if not self:saveConfiguration(config) then
			success = false
		end
	end

	return success
end

function acrexttConfigurationManager:deleteConfiguration(configName : string)
	if not configName then
		warn(`Can't delete configuration without name.`)
		return false
	end

	return deleteConfigFile(configName)
end

function acrexttConfigurationManager:changeConfigurationName(oldName : string, newName : string) : any
	if not newName then
		warn(`Can't change configuration name without newName.`)
		return nil
	elseif not oldName then
		warn(`Can't change configuration name without oldName.`)
		return nil
	end

	local existingConfigs = listConfigFiles()
	if table.find(existingConfigs, newName) then
		warn(`Configuration "${newName}" already exists.`)
		return nil
	end

	local oldConfig = loadConfigFromFile(oldName)
	if not oldConfig then
		warn(`Configuration "${oldName}" doesn't exist!`)
		return nil
	end

	oldConfig.name = newName
	oldConfig.lastModified = os.time()

	if saveConfigToFile(newName, oldConfig) then
		deleteConfigFile(oldName)
		return oldConfig
	end

	return nil
end

function acrexttConfigurationManager:getMaxConfigurations()
	return maxConfigurations
end

function acrexttConfigurationManager:setMaxConfigurations(newMax : number)
	if type(newMax) ~= "number" or newMax < 1 then
		warn(`Invalid max configurations value: ${newMax}`)
		return false
	end

	maxConfigurations = newMax
	return true
end

function acrexttConfigurationManager:exportConfiguration(configName : string)
	if not configName then
		warn(`Can't export configuration without name.`)
		return nil
	end

	local config = loadConfigFromFile(configName)
	if not config then
		warn(`Configuration "${configName}" doesn't exist!`)
		return nil
	end

	local exportData = {
		metadata = {
			exportedAt = os.time(),
			version = config.data.version or "1.0",
			configName = config.name
		},
		configuration = config.data
	}

	return HttpService:JSONEncode(exportData)
end

function acrexttConfigurationManager:importConfiguration(importData : string, configName : string)
	if not importData then
		warn(`No import data provided.`)
		return false
	end

	local success, decoded = pcall(function()
		return HttpService:JSONDecode(importData)
	end)

	if not success then
		warn(`Invalid import data format.`)
		return false
	end

	local configToSave = {
		name = configName or decoded.metadata.configName or "imported_" .. os.time(),
		createdAt = os.time(),
		lastModified = os.time(),
		data = decoded.configuration or decoded
	}

	return self:saveConfiguration(configToSave)
end

function acrexttConfigurationManager:getConfigurationInfo(configName : string)
	if not configName then
		warn(`Can't get info without config name.`)
		return nil
	end

	local config = loadConfigFromFile(configName)
	if not config then
		return nil
	end

	return {
		name = config.name,
		createdAt = config.createdAt,
		lastModified = config.lastModified,
		size = 0,
		isDefault = config.name == "default"
	}
end

return acrexttConfigurationManager