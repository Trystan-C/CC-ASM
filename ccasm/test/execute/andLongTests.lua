assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    andDataRegisters = function()
        fixture.assemble([[
            moveLong #hFFFFFFFF, d0
            moveLong #hAAAAAAAA, d1
            andLong d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xAAAAAAAA);
    end,

    andImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveLong #hAAAAAAAA, d0
            andLong #h55555555, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0);
    end,

    andOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("andLong #h1234ABCD5678, d0");
        end);
    end,

    andInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("andLong d0, #1");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("andLong #1, a0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                andLong #h1234ABCD, var
                var declareLong #hFFFFFFFF
            ]]);
        end);
    end,

};

return testSuite;