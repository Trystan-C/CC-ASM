assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    shiftDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            lshiftByte d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x34ABCD00);
    end,

    shiftAddressRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, a0
            lshiftByte a0
        ]])
            .load()
            .step(2)
            .addressRegister(0).hasValue(0x34ABCD00);
    end,

    shiftInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                lshiftByte var
                var declareWord #h1234
            ]]);
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                lshiftByte #h12
            ]]);
        end);
    end,

};

return testSuite;