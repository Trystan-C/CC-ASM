assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    compareDataRegisters = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte d1, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);

        fixture.assemble([[
            moveByte #1, d0
            moveByte #2, d1
            cmpByte d1, d0
        ]])
            .load()
            .step(3)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(1);

        fixture.assemble([[
            moveByte #1, d0
            moveByte #1, d1
            cmpByte d1, d0
        ]])
            .load()
            .step(3)
            .statusRegister().comparisonFlagIs(0)
            .statusRegister().negativeFlagIs(0);
    end,

    compareImmediateData = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte #1, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(0);

        fixture.assemble([[
            moveByte #1, d0
            cmpByte #2, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(1)
            .statusRegister().negativeFlagIs(1);

        fixture.assemble([[
            moveByte #1, d0
            cmpByte #1, d0
        ]])
            .load()
            .step(2)
            .statusRegister().comparisonFlagIs(0)
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