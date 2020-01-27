assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local fixture = cpuTestFixture;

local testSuite = {

    moveImmediateDecimalLongToDataRegister = function()
        fixture.assemble("moveLong #" .. math.pow(2, 16) .. ", D3")
            .load()
            .step()
            .dataRegister(3).hasValue(math.pow(2, 16));
    end,

    moveImmediateHexLongToDataRegister = function()
        fixture.assemble("moveLong #hAABBCCDD, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xAABBCCDD);
    end,

    moveImmediateBinaryLongToDataRegister = function()
        fixture.assemble("moveLong #b000000100, D2")
            .load()
            .step()
            .dataRegister(2).hasValue(4);
    end,

    moveLongFromSymbolicAddressToDataRegister = function()
        fixture.assemble([[
            moveLong var, d0
            var declareLong #hAABBCCDD
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(0xAABBCCDD);
    end,

    moveImmediateDecimalLongToAddressRegister = function()
        fixture.assemble("moveLong #112000, a0")
            .load()
            .step()
            .addressRegister(0).hasValue(112000);
    end,

    moveImmediateHexLongToAddressRegister = function()
        fixture.assemble("moveLong #h12ABCDEF, A4")
            .load()
            .step()
            .addressRegister(4).hasValue(0x12ABCDEF);
    end,

    moveImmediateBinaryLongToAddressRegister = function()
        fixture.assemble("moveLong #b101101110001101101, a6")
            .load()
            .step()
            .addressRegister(6).hasValue(tonumber("101101110001101101", 2));
    end,

    moveLongFromSymbolicAddressToAddressRegister = function()
        fixture.assemble([[
            moveLong var, d0
            var declareLong #hFF001122
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(0xFF001122);
    end,

    moveLongAbsoluteAddress = function()
        fixture.assemble([[
            moveLong #h1234ABCD, >h1000
            moveLong >h1000, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    moveLongFromIndirectAddress = function()
        fixture.assemble([[
            moveWord #var, a0
            moveLong #a0, d0
            var declareLong #h1234ABCD
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    moveLongToIndirectAddress = function()
        fixture.assemble([[
            moveWord #h1000, a0
            moveLong #h1234ABCD, #a0
            moveLong #a0, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    moveLongDirectlyBetweenAddressesThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble([[
                    moveLong var1, var2
                    var1 declareLong #h1234ABCD
                    var2 declareLong #h5678ABCD
                ]]);
            end,
            function()
                fixture.assemble([[
                    moveLong var1, >h1000
                    var1 declareLong #h1234ABCD
                ]]);
            end,
            function()
                fixture.assemble([[
                    moveLong >h1000, var1
                    var1 declareLong #h1234ABCD
                ]]);
            end,
            function()
                fixture.assemble([[
                    moveLong var, #a0
                    var declareLong #h1234ABCD
                ]]);
            end,
            function()
                fixture.assemble([[
                    moveLong #a0, var
                    var declareLong #h1234
                ]]);
            end,
            function()
                fixture.assemble("moveLong >h1000, #a0");
            end,
            function()
                fixture.assemble("moveLong #a0, >h1000");
            end,
            function()
                fixture.assemble("moveLong #a0, #a1");
            end,
            function()
                fixture.assemble("moveLong >h1000, >h1002");
            end
        );
    end,

};

return testSuite;