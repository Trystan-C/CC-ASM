assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    subByteFromDataRegister = function()
        fixture.assemble([[
            moveByte #25, d0
            subByte #10, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(15);
    end,

};

return testSuite;