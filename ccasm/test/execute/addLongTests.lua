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

    addLongImmediateToAddressRegister = function()
        fixture.assemble("moveLong #66000, A3")
            .load()
            .step()
            .addressRegister(3).hasValue(66000);
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

    addAddressRegisters = function()
        fixture.assemble([[
            moveLong #hCCCC0000, a3
            moveLong #h0000DDDD, a4
            addLong a3, a4
        ]])
            .load()
            .step(3)
            .addressRegister(4).hasValue(0xCCCCDDDD);
    end,

    addDataRegisterToAddressRegister = function()
        fixture.assemble([[
            moveLong #hFFFF0000, d0
            moveLong #h0000EEEE, a0
            addLong d0, a0
        ]])
            .load()
            .step(3)
            .addressRegister(0).hasValue(0xFFFFEEEE);
    end,

    addAddressRegisterToDataRegister = function()
        fixture.assemble([[
            moveLong #h12340000, A2
            moveLong #h00005678, d5
            addLong a2, D5
        ]])
            .load()
            .step(3)
            .dataRegister(5).hasValue(0x12345678);
    end,

    addLongFromSymbolicAddress = function()
        fixture.assemble([[
            moveLong mem, D4
            mem declareLong #hFFEE1122
        ]])
            .load()
            .step()
            .dataRegister(4).hasValue(0xFFEE1122);
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