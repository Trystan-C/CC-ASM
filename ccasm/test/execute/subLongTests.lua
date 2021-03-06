assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/assert/expect.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    subLongFromDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d1
            subLong #h12340000, d1
        ]])
            .load()
            .step(2)
            .dataRegister(1).hasValue(0xABCD);
    end,

    subLongCanOverflow = function()
        fixture.assemble("subLong #1, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFFFFFFFF);
    end,

    subLongFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveLong #hAABBCCDD, a0
                subLong #hAABB0000, a0
            ]]);
        end);
    end,

    subLongAtSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveLong #hABCDEF12, D3
                subLong sym, d3
                sym declareLong #hABCD0000
            ]]);
        end);
    end,

    subLongFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                subLong #hEFDDAABB, var
                var declareWord #hABCDEF12
            ]]);
        end);
    end,

    subLongOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("subLong #h1234ABCD5678, d0");
        end);
    end,

};

return testSuite;