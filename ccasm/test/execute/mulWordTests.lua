assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/assert/expect.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    multiplyDataRegisters = function()
        fixture.assemble([[
            moveWord var, d0
            moveWord #2, d1
            mulWord d0, d1
            var declareWord #h1234
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0x2468);
    end,

    multiplyImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveWord #h1234, d0
            mulWord #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x2468);
    end,

    multiplicationIsSigned = function()
        fixture.assemble([[
            moveWord #1, d0
            mulWord #hFFFF, d0
            moveWord #hFFFF, d1
            mulWord #hFFFF, d1
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xFFFF)
            .dataRegister(1).hasValue(1);
    end,

    multiplyFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveWord #h1234, a0
                moveWord #1, d0
                mulWord a0, d0
            ]]);
        end);
    end,

    multiplyToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveWord #1, d0
                moveWord #2, a0
                mulWord d0, a0
            ]]);
        end);
    end,

    multiplyOnlyAffectsLowerWord = function()
        fixture.assemble([[
            moveLong #h12340000, d0
            mulWord #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x12340000);
    end,

    multiplyOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("mulWord #h1234ABCD, D4");
        end);
    end,

    multiplyFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                mulWord var, d0
                var declareWord #h1234
            ]]);
        end);
    end,

    multiplyToSymoblicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                mulWord d3, var
                var declareWord #h1234
            ]]);
        end);
    end,

};

return testSuite;