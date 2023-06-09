--- The optional CoreTest package.
-- @script CoreTest
-- @license Apache License 2.0
-- @copyright GrayWolf64

concommand.Add("log4g_load_coretest", function()
    Log4g.CoreTest = Log4g.CoreTest or {}

    function Log4g.CoreTest.randomString(len)
        local res = ""

        for i = 1, len do
            res = res .. string.char(math.random(97, 122))
        end

        return res
    end

    include"log4g/core-test/TestLoggerContext.lua"
    include"log4g/core-test/TestLogger.lua"
end)