assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));

local fixture = cpuTestFixture;

local testSuite = {

    addDataRegisters = function()
        fixture.assemble([[
            moveByte #5, d1
            moveByte #5, d2
            addByte d1, d2
        ]])
            .load()
            .step(3)
            .dataRegister(2).hasValue(10);
    end,

    addImmediateDataToDataRegister = function()
        fixture.assemble([[
            addByte #13, d6
        ]])
            .load()
            .step()
            .dataRegister(6).hasValue(13);
    end,

    addOnlyAffectsLowerByte = function()
        fixture.assemble([[
            moveWord #h12FF, d0
            addByte #1, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x1200);
    end,

    addByteWithOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addByte #h1234, d0");
        end);
    end,

    addFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addByte a0, d0");
        end);
    end,

    addToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addByte #3, a2");
        end);
    end,

    addSymbolToDataRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                var declareByte hFF
                addByte var, d0
            ]]);
        end);
    end,
    
    addImmediateDataTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("addByte #256, D3");
        end);
    end,

};

return testSuite;
