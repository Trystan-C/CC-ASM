assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    compareDataRegisters = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            moveLong #h1234ABCD, d1
            cmpLong d0, d1
        ]])
            .load()
            .step(3)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    compareImmediateDataWithDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            cmpLong #h1234ABCE, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(0);
    end,

    compareDataRegisterWithImmediateData = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            cmpLong d0, #h1234ABCE
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(1);
    end,

    compareImmediateData = function()
        fixture.assemble("cmpLong #h1234ABCD, #h1234ABCD")
            .load()
            .step()
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    compareAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("cmpLong #1, A4");
        end);
    end,

    compareOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("cmpLong #h1234ABCD5678, d0");
        end);
    end,

};

return testSuite;