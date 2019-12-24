assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    subWordFromDataRegister = function()
        fixture.assemble([[
            moveWord #hABCD, d1
            subWord #hAB00, d1
        ]])
            .load()
            .step(2)
            .dataRegister(1).hasValue(0xCD);
    end,

    subWordCanOverflow = function()
        fixture.assemble("subWord #1, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFFFF);
    end,

    subWordFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveWord #hAABB, a0
                subWord #hAA00, a0
            ]]);
        end);
    end,

    subWordAtSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveWord #hABCD, D3
                subWord sym, d3
                sym declareWord #hAB00
            ]]);
        end);
    end,

    subWordFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                subWord #hEFDD, var
                var declareWord #hABCD
            ]]);
        end);
    end,

    subWordAffectsOnlyLowerWord = function()
        fixture.assemble([[
            moveLong #h12340000, d0
            subWord #1, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x1234FFFF);
    end,

    subWordOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("subWord #h1234ABCD, d0");
        end);
    end,

};

return testSuite;