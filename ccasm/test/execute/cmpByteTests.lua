assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    compareDataRegisters = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte d0, d1
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(0);
    end,

    compareImmediateDataWithDataRegister = function()
        fixture.assemble([[
            moveByte #3, d0
            cmpByte #2, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(1);
    end,

    compareDataRegisterWithImmediateData = function()
        fixture.assemble("cmpByte d0, #0")
            .load()
            .step()
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    compareImmediateData = function()
        fixture.assemble("cmpByte #1, #1")
            .load()
            .step()
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    comparisonOnlyConsidersLowerByte = function()
        fixture.assemble([[
            moveWord #h1234, d0
            cmpByte #h34, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    compareWithOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("cmpByte #h1234, d0");
        end);
    end,

    compareAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("cmpByte #1, a0");
        end);
    end,

};

return testSuite;