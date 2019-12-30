assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    compareImmediateDataWithDataRegister = function()
        fixture.assemble([[
            moveWord #h1234, d0
            cmpWord #h1235, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(0);
    end,

    compareDataRegisterWithImmediateData = function()
        fixture.assemble([[
            moveWord #h1233, d0
            cmpWord d0, #h1234
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(1);
    end,

    compareDataRegisters = function()
        fixture.assemble("cmpWord d0, d0")
            .load()
            .step()
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    compareImmediateDataWithImmediateData = function()
        fixture.assemble("cmpWord #1, #1")
            .load()
            .step()
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    comparisonOnlyConsidersLowerWord = function()
        fixture.assemble([[
            moveLong #h12345678, d0
            cmpWord #h5678, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);
    end,

    compareAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("cmpWord #1, a0");
        end);
    end,

    compareOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("cmpWord #h1234ABCD, d0");
        end);
    end,

};

return testSuite;