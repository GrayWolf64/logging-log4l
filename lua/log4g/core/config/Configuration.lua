--- Interface that must be implemented to create a Configuration.
-- Subclassing `LifeCycle`, mixin-ing `SetContext()` and `GetContext()`.
-- @classmod Configuration
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.Configuration = Log4g.Core.Config.Configuration or {}
local LifeCycle = Log4g.Core.LifeCycle.getClass()
local checkClass = include"../util/TypeUtil.lua".checkClass
local Configuration = Configuration or LifeCycle:subclass"Configuration"
Configuration:include(Log4g.Core.Object.contextualMixins)
local SysTime = SysTime

function Configuration:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField(0x0015, {})
    self:SetPrivateField(0x0013, {})
    self:SetPrivateField(0x00AB, SysTime())
    self:SetName(name)
end

function Configuration:__tostring()
    return "Configuration: [name:" .. self:GetName() .. "]"
end

--- Adds a Appender to the Configuration.
-- @param appender The Appender to add
-- @return bool ifsuccessful
function Configuration:AddAppender(ap)
    if not checkClass(ap, "Appender") then return end
    if self:GetPrivateField(0x0015)[ap:GetName()] then return false end
    self:GetPrivateField(0x0015)[ap:GetName()] = ap

    return true
end

function Configuration:RemoveAppender(name)
    self:GetPrivateField(0x0015)[name] = nil
end

--- Gets all the Appenders in the Configuration.
-- Keys are the names of Appenders and values are the Appenders themselves.
-- @return table appenders
function Configuration:GetAppenders()
    return self:GetPrivateField(0x0015)
end

function Configuration:AddLogger(name, lc)
    self:GetPrivateField(0x0013)[name] = lc
end

--- Locates the appropriate LoggerConfig name for a Logger name.
-- @param name The Logger name
-- @return object loggerconfig
function Configuration:GetLoggerConfig(name)
    return self:GetPrivateField(0x0013)[name]
end

function Configuration:GetLoggerConfigs()
    return self:GetPrivateField(0x0013)
end

function Configuration:GetRootLogger()
    return self:GetPrivateField(0x0013)[GetConVar("log4g_rootLoggerName"):GetString()]
end

--- Gets how long since this Configuration initialized.
-- @return int uptime
function Configuration:GetUpTime()
    return SysTime() - self:GetPrivateField(0x00AB)
end

--- Create a Configuration.
-- @param name The name of the Configuration
-- @return object configuration
function Log4g.Core.Config.Configuration.create(name)
    if type(name) ~= "string" then return end

    return Configuration(name)
end

function Log4g.Core.Config.Configuration.getClass()
    return Configuration
end