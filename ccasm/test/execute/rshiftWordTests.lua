assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    shiftDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            rshiftWord d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x00001234);
    end,

    shiftAddressRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, a0
            rshiftWord a0
        ]])
            .load()
            .step(2)
            .addressRegister(0).hasValue(0x00001234);
    end,

    shiftInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                rshiftWord my_var
                my_var declareWord #hABCD
            ]]);
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("rshiftWord #h1234");
        end);
    end,

};

return testSuite;