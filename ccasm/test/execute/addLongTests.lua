assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {
    
    addLongImmediateToDataRegister = function()
        fixture.assemble("moveLong #hABCDEF12, D1")
            .load()
            .step()
            .dataRegister(1).hasValue(0xABCDEF12);
    end,

    addDataRegisters = function()
        fixture.assemble([[
            moveLong #h0000BBBB, d5
            moveLong #hAAAA0000, d6
            addLong d5, d6
        ]])
            .load()
            .step(3)
            .dataRegister(6).hasValue(0xAAAABBBB);
    end,

    addLongFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                addLong a3, d4
            ]]);
        end);
    end,

    addLongToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                addLong d5, a2
            ]]);
        end);
    end,

    addLongFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                addLong mem, D4
                mem declareLong #hFFEE1122
            ]]);
        end);
    end,

    addLongToSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                addLong #hAABBCCDD, mem
                mem declareLong #0
            ]]);
        end);
    end,

};

return testSuite;