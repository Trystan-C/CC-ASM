assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    subWordFromDataRegister = function()
        fixture.assemble([[
            moveWord #hABCD, d1
            subWord #hAB00, d1
        ]])
            .load()
            .step(2)
            .dataRegister(1).hasValue(0xCD);
    end,

    subWordCanOverflow = function()
        fixture.assemble("subWord #1, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFFFF);
    end,

};

return testSuite;