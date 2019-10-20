assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    moveWordFromSymbolToDataRegister = function()
        fixture.assemble([[
            moveWord x, d0
            x declareWord #25
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(25);
    end,

    moveByteFromDataRegisterToSymbolicAddress = function()
        fixture.assemble([[
            moveWord #5, d0
            moveWord d0, var
            moveWord var, d6
            var declareWord #6
        ]])
            .load()
            .step(3)
            .dataRegister(6).hasValue(5);
    end

};

return testSuite;