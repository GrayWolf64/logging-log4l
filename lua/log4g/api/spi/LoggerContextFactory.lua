--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local HasKey = Log4g.Util.HasKey
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register
local GetAllLoggerContexts = Log4g.Core.LoggerContext.GetAll
local GetCurrentFQSN = Log4g.Util.GetCurrentFQSN

--- Create a LoggerContext.
-- @param name The name of the LoggerContext
function Log4g.API.LoggerContextFactory.GetContext(func)
    RegisterLoggerContext(GetCurrentFQSN(func))
end

--- Check if a LoggerContext with the given name exists.
-- If the LoggerContext exists, return true.
-- @param name The name of the LoggerContext
-- @return bool hascontext
function Log4g.API.LoggerContextFactory.HasContext(name)
    return HasKey(GetAllLoggerContexts(), name)
end