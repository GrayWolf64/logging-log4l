--- The LoggerConfig.
-- @classmod LoggerConfig
local HasKey = Log4g.Util.HasKey
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED

--- Initialize the LoggerConfig object.
-- This is meant to be used internally.
-- @param tbl The table containing the necessary data to make a LoggerConfig
function LoggerConfig:Initialize(name)
    SetState(self, INITIALIZING)
    self.name = name
    SetState(self, INITIALIZED)
end

--- Get the name of the LoggerConfig, same to `loggerconfig.name`.
function LoggerConfig:GetName()
    return self.name
end

--- Get the LoggerContext name of the LoggerConfig.
function LoggerConfig:GetContext()
    return self.loggercontext
end

--- All the LoggerConfigs will be stored here.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Remove the LoggerConfig.
function LoggerConfig:Remove()
    SetState(self, STOPPING)
    SetState(self, STOPPED)
    INSTANCES[self.name] = nil
end

--- Get all the LoggerConfigs in the LoggerConfigs table.
-- @return table instances
function Log4g.Core.Config.LoggerConfig.GetAll()
    return INSTANCES
end

--- Remove all the LoggerConfig instances with the provided LoggerContext name.
-- @param name The name of the LoggerContext
function Log4g.Core.Config.LoggerConfig.RemoveByContext(name)
    if table.IsEmpty(INSTANCES) then return end

    for k, v in pairs(INSTANCES) do
        if v:GetContext() == name then
            INSTANCES[k]:Remove()
        end
    end
end

--- Get the LoggerConfig with the right name.
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Get(name)
    if HasKey(INSTANCES, name) then return INSTANCES[name] end
end

--- Register a LoggerConfig.
-- @param name The name for the LoggerConfig
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(name)
    if not HasKey(INSTANCES, name) then
        local loggerconfig = LoggerConfig:New(name)
        INSTANCES[name] = loggerconfig

        return INSTANCES[name]
    else
        return INSTANCES[name]
    end
end