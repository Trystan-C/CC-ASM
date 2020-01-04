assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    shiftDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d0
            lshiftWord d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xABCD0000);
    end,

    shiftAddressRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, a3
            lshiftWord A3
        ]])
            .load()
            .step(2)
            .addressRegister(3).hasValue(0xABCD0000);
    end,

    shiftInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                lshiftWord sym
                sym declareLong #h1234ABCD
            ]]);
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                lshiftWord #h1234ABCD
            ]]);
        end);
    end,

};

return testSuite;