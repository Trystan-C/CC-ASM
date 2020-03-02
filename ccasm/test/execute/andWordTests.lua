assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    andDataRegisters = function()
        fixture.assemble([[
            moveWord #hFFFF, d0
            moveWord #hAAAA, d1
            andWord d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xAAAA);
    end,

    andImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveWord #hAAAA, d0
            andWord #h5555, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0);
    end,

    andOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("andWord #h1234ABCD, d0");
        end);
    end,

    andInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("andWord d0, #1");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("andWord #1, a0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                andWord #h1234, var
                var declareWord #hFFFF
            ]]);
        end);
    end,

};

return testSuite;