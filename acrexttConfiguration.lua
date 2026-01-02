
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local acrexttConfigurationManager = {}
local configurationTemplate = {
    version = "1.0",
    keybinds = {
        openHubInput = Enum.KeyCode.Insert,
        aimbotKey = "MouseButton2",
        flyKey = Enum.KeyCode.F,
        noclipKey = Enum.KeyCode.N
    },
    settings = {
        -- Movement
        walkSpeed = 16,
        jumpPower = 50,
        jumpHeight = 7.2,
        infiniteJump = false,
        noClip = false,
        flyEnabled = false,
        flySpeed = 50,
        
        -- Aim
        AimbotEnabled = false,
        AimbotFOV = 100,
        AimbotSmoothness = 0.12,
        aimbotPart = "Head",
        AimbotPredictionStrength = 0.5,
        IgnoreFriends = false,
        IgnoreTeam = true,
        EnemiesOnly = false,
        
        -- Visuals
        boxESP = false,
        tracers = false,
        nameTags = true,
        healthBar = true,
        
        -- World
        fullBright = false,
        
        -- Utility
        antiAFK = false
    }
}
local maxConfigurations = 3

local function getConfigKey()
	return "acrextt_configuration_2026_" .. tostring(Player.UserId)
end

local LAST_LOADED_KEY = getConfigKey() .. "_lastLoaded"

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

function acrexttConfigurationManager:formatTimeSince(seconds)
    if seconds < 60 then
        return seconds .. " seconds ago"
    elseif seconds < 3600 then
        return math.floor(seconds / 60) .. " minutes ago"
    elseif seconds < 86400 then
        return math.floor(seconds / 3600) .. " hours ago"
    else
        return math.floor(seconds / 86400) .. " days ago"
    end
end

function acrexttConfigurationManager:getTimeSinceLastLoad()
    local lastLoaded = self:getLastLoadedConfiguration()
    if lastLoaded then
        local timeSince = os.time() - lastLoaded.timestamp
        return {
            seconds = timeSince,
            minutes = math.floor(timeSince / 60),
            hours = math.floor(timeSince / 3600),
            days = math.floor(timeSince / 86400),
            formatted = self:formatTimeSince(timeSince)
        }
    end
    return nil
end

function acrexttConfigurationManager:validateConfiguration(config)
    if not config then return false end
    
    if not config.data then return false end
    if not config.data.settings then return false end
    if not config.data.keybinds then return false end
    
    for key, value in pairs(configurationTemplate.settings) do
        if config.data.settings[key] == nil then
            config.data.settings[key] = value
        end
    end
    
    for key, value in pairs(configurationTemplate.keybinds) do
        if config.data.keybinds[key] == nil then
            config.data.keybinds[key] = value
        end
    end
    
    return true
end

function acrexttConfigurationManager:getLastLoadedConfiguration()
    if readfile and isfile then
        local fileName = LAST_LOADED_KEY .. ".json"
        if isfile(fileName) then
            local success, data = pcall(function()
                local fileData = readfile(fileName)
                return HttpService:JSONDecode(fileData)
            end)
            
            if success and data then
                local actualConfig = loadConfigFromFile(data.name)
                if actualConfig then
                    data.configuration = actualConfig.data
                end
                return data
            end
        end
    end
    return nil
end

function acrexttConfigurationManager:isLastLoadedConfiguration(configName : string)
    local lastLoaded = self:getLastLoadedConfiguration()
    if lastLoaded then
        return lastLoaded.name == configName
    end
    return false
end

function acrexttConfigurationManager:getCurrentConfiguration()
    local lastLoaded = self:getLastLoadedConfiguration()
    if lastLoaded and lastLoaded.name then
        return self:getConfiguration(lastLoaded.name)
    end
    return self:getConfiguration("default")
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

function acrexttConfigurationManager:getConfigurations() : any
    return self:loadConfigurations()
end

function acrexttConfigurationManager:loadConfiguration(specificConfiguration : string) : any
    if not specificConfiguration then
        warn(`Specific configuration not given returning default configuration.`)
        local defaultConfig = createDefaultConfig("default")
        
        self:setLastLoadedConfiguration("default", defaultConfig.data)
        
        return defaultConfig
    end
    
    local loadedConfig = loadConfigFromFile(specificConfiguration)
    if loadedConfig then
        self:setLastLoadedConfiguration(specificConfiguration, loadedConfig.data)
        
        return loadedConfig
    end
    
    local newConfig = createDefaultConfig(specificConfiguration)
    saveConfigToFile(specificConfiguration, newConfig)
    
    self:setLastLoadedConfiguration(specificConfiguration, newConfig.data)
    
    return newConfig
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
    
    local configName = configuration.name or "default"
    local configData = configuration.data or configuration
    
    local configToSave = {
        name = configName,
        createdAt = configuration.createdAt or os.time(),
        lastModified = os.time(),
        data = configData
    }
    
    if not self:validateConfiguration(configToSave) then
        warn("Invalid configuration structure")
        return false
    end
    
    local existingConfigs = listConfigFiles()
    if #existingConfigs >= maxConfigurations and not table.find(existingConfigs, configName) then
        warn(`Maximum configurations (${maxConfigurations}) reached. Delete one before saving.`)
        return false
    end
    
    local success = saveConfigToFile(configName, configToSave)
    
    if success then
        self:setLastLoadedConfiguration(configName, configData)
    end
    
    return success
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

function acrexttConfigurationManager:setLastLoadedConfiguration(configName : string, configData : any)
    if writefile then
        local lastLoadedData = {
            name = configName,
            timestamp = os.time(),
            humanTime = os.date("%Y-%m-%d %H:%M:%S", os.time()),
            configReference = {
                name = configName,
                lastModified = os.time()
            }
        }
        
        if configData then
            lastLoadedData.preview = {
                walkSpeed = configData.settings and configData.settings.walkSpeed,
                aimbotEnabled = configData.settings and configData.settings.AimbotEnabled,
                espEnabled = configData.settings and (configData.settings.boxESP or configData.settings.tracers)
            }
        end
        
        local fileName = LAST_LOADED_KEY .. ".json"
        writefile(fileName, HttpService:JSONEncode(lastLoadedData))
    end
end
			
function acrexttConfigurationManager:deleteConfiguration(configName : string)
	if not configName then
		warn(`Can't delete configuration without name.`)
		return false
	end

	return deleteConfigFile(configName)
end

function acrexttConfigurationManager:clearLastLoadedTracking()
    if delfile and isfile then
        local fileName = LAST_LOADED_KEY .. ".json"
        if isfile(fileName) then
            delfile(fileName)
            return true
        end
    end
    return false
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
