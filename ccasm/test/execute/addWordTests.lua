assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    addWordImmediateToDataRegister = function()
        fixture.assemble("addWord #hABCD, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xABCD);
    end,

};

return testSuite;