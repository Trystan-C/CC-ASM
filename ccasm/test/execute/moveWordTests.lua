assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    moveWordBetweenDataRegisters = function()
        fixture.assemble([[
            moveWord #hABEF, d0
            moveWord d0, d4
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xABEF)
            .dataRegister(4).hasValue(0xABEF);
    end,

    moveWordBetweenAddressRegisters = function()
        fixture.assemble([[
            moveWord #hFFFF, a3
            moveWord a3, a4
        ]])
            .load()
            .step(2)
            .addressRegister(3).hasValue(0xFFFF)
            .addressRegister(4).hasValue(0xFFFF);
    end,

    moveWordFromDataRegisterToAddressRegister = function()
        fixture.assemble([[
            moveWord #hABCD, d0
            moveWord d0, a0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xABCD)
            .addressRegister(0).hasValue(0xABCD);
    end,

    moveWordImmediateToDataRegiser = function()
        fixture.assemble([[
            moveWord #25, d0
            moveWord #h32, d1
            moveWord #b111, d2
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(25)
            .dataRegister(1).hasValue(0x32)
            .dataRegister(2).hasValue(7);
    end,

    moveWordImmediateToAddressRegister = function()
        fixture.assemble([[
            moveWord #25, a0
            moveWord #h32, a1
            moveWord #b111, a2
        ]])
            .load()
            .step(3)
            .addressRegister(0).hasValue(25)
            .addressRegister(1).hasValue(0x32)
            .addressRegister(2).hasValue(7);
    end,

    moveWordFromSymbolToDataRegister = function()
        fixture.assemble([[
            moveWord x, d0
            x declareWord #25
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(25);
    end,

    moveByteFromDataRegisterToSymbolicAddress = function()
        fixture.assemble([[
            moveWord #5, d0
            moveWord d0, var
            moveWord var, d6
            var declareWord #6
        ]])
            .load()
            .step(3)
            .dataRegister(6).hasValue(5);
    end

};

return testSuite;