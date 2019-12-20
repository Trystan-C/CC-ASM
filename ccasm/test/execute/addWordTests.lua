assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    addDataRegisters = function()
        fixture.assemble([[
            moveWord #hAB00, d0
            moveWord #h00CD, d1
            addWord d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xABCD);
    end,

    addWordImmediateToDataRegister = function()
        fixture.assemble("addWord #hABCD, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xABCD);
    end,

};

return testSuite;