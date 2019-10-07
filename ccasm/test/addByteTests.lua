assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");

local fixture = cpuTestFixture;

local testSuite = {

    addDataRegisters = function()
        fixture.assemble([[
            moveByte #5, d1
            moveByte #5, d2
            addByte d1, d2
        ]])
            .load()
            .step(3)
            .dataRegister(2).hasValue(10);
    end,

};

return testSuite;