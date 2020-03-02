assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    addDataRegisters = function()
        fixture.assemble([[
            moveWord #hAB00, d0
            moveWord #h00CD, d1
            addWord d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xABCD);
    end,

    addWordImmediateToDataRegister = function()
        fixture.assemble("addWord #hABCD, d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xABCD);
    end,

    addWordOnlyAffectsLowerWord = function()
        fixture.assemble([[
            moveLong #h1234FFFF, d0
            addWord #1, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x12340000);
    end,

    addWordWithOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addWord #h1234ABCD, d0");
        end);
    end,
    
    addWordFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addWord a2, d5");
        end);
    end,

    addWordToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addWord d3, a4");
        end);
    end

};

return testSuite;