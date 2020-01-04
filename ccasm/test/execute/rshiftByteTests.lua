assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    shiftDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            rshiftByte d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x001234AB);
    end,

    shiftAddressRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, a0
            rshiftByte a0
        ]])
            .load()
            .step(2)
            .addressRegister(0).hasValue(0x001234AB);
    end,

    shiftInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                rshiftByte my_var
                my_var declareWord #hABCD
            ]]);
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("rshiftByte #h1234");
        end);
    end,

};

return testSuite;