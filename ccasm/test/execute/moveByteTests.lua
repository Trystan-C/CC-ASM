assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    moveByteBetweenDataRegisters = function()
        fixture.assemble([[
            moveByte #5, d0
            moveByte d0, d3
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(5)
            .dataRegister(3).hasValue(5);
    end,

    moveByteImmediateToDataRegister = function()
        fixture.assemble([[
            moveByte #10, d1
            moveByte #hFF, d2
            moveByte #b101, d3
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(10)
            .dataRegister(2).hasValue(0xFF)
            .dataRegister(3).hasValue(5);
    end,

    moveByteBetweenAddressRegisters = function()
        fixture.assemble([[
            moveByte #hA3, a0
            moveByte a0, a5
        ]])
            .load()
            .step(2)
            .addressRegister(0).hasValue(0xA3)
            .addressRegister(5).hasValue(0xA3);
    end,

    moveByteFromWordToDataRegister = function()
        fixture.assemble([[
            moveByte word, d6
            word declareWord #hABEF
        ]])
            .load()
            .step()
            .dataRegister(6).hasValue(0xAB);
    end,

    moveByteFromSymbolToDataRegister = function()
        fixture.assemble([[
            moveByte x, d0
            x declareByte #25
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(25);
    end,

    moveByteFromDataRegisterToSymbolicAddress = function()
        fixture.assemble([[
            moveByte #5, d0
            moveByte d0, var
            moveByte var, d6
            var declareByte #6
        ]])
            .load()
            .step(3)
            .dataRegister(6).hasValue(5);
    end,

    moveByteAbsoluteAddress = function()
        fixture.assemble([[
            moveByte #13, >h1000
            moveByte >h1000, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(13);
    end,

    moveByteIndirectAddress = function()
        fixture.assemble([[
            moveWord #var, a0
            moveByte #a0, d0
            var declareByte #hAB
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xAB);
    end,

    moveByteDirectlyBetweenAddressesThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble([[
                    moveByte var1, var2
                    var1 declareByte #1
                    var2 declareByte #2
                ]]);
            end,
            function()
                fixture.assemble([[
                    moveByte var1, >h1000
                    var1 declareByte #1
                ]]);
            end,
            function()
                fixture.assemble([[
                    moveByte >h1000, var1
                    var1 declareByte #1
                ]]);
            end,
            function()
                fixture.assemble("moveByte >h1000, >h1001");
            end
        );
    end,

};

return testSuite;