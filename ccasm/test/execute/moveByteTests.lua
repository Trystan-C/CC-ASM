assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    moveByteFromSymbolToDataRegister = function()
        fixture.assemble([[
            moveByte x, d0
            x declareByte #25
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(25);
    end,

    moveByteFromDataRegisterToSymbolicAddress = function()
        fixture.assemble([[
            moveByte #5, d0
            moveByte d0, var
            moveByte var, d6
            var declareByte #6
        ]])
            .load()
            .step(3)
            .dataRegister(6).hasValue(5);
    end

};

return testSuite;