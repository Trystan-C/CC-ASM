assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local fixture = cpuTestFixture;

local testSuite = {

    moveImmediateDecimalLongToDataRegister = function()
        fixture.assemble("moveLong #" .. math.pow(2, 16) .. ", D3")
            .load()
            .step()
            .dataRegister(3).hasValue(math.pow(2, 16));
    end,

    moveImmediateHexLongToDataRegister = function()
        fixture.assemble("moveLong #hAABBCCDD, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xAABBCCDD);
    end,

    moveImmediateBinaryLongToDataRegister = function()
        fixture.assemble("moveLong #b000000100, D2")
            .load()
            .step()
            .dataRegister(2).hasValue(4);
    end,

};

return testSuite;