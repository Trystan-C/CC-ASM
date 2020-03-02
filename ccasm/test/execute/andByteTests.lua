assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    andDataRegisters = function()
        fixture.assemble([[
            moveByte #hFF, d0
            moveByte #hAA, d1
            andByte d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xAA);
    end,

    andImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveByte #hAA, d0
            andByte #h55, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0);
    end,

    andOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("andByte #h1234, d0");
        end);
    end,

    andInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("andByte d0, #1");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("andByte #1, a0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                andByte #1, var
                var declareByte #hFF
            ]]);
        end);
    end,

};

return testSuite;