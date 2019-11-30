assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    subByteFromDataRegister = function()
        fixture.assemble([[
            moveByte #25, d0
            subByte #10, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(15);
    end,

    subWordFromDataRegister = function()
        fixture.assemble([[
            moveWord #hABCD, d1
            subWord #hAB00, d1
        ]])
            .load()
            .step(2)
            .dataRegister(1).hasValue(0xCD);
    end,

    subByteCanOverflow = function()
        fixture.assemble([[
            moveByte #1, d0
            subByte #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFF);
    end,

    subWordCanOverflow = function()
        fixture.assemble("subWord #1, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFFFF);
    end,

    subByteFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #32, a3
                subByte #22, a3
            ]]);
        end);
    end,

    subByteAtSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #10, d0
                subByte x, d0
                x declareByte #5
            ]]);
        end);
    end,

    subByteFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                subByte #15, x
                x declareByte #20
            ]]);
        end);
    end,

};

return testSuite;