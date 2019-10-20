assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");

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

    addAddressRegisterToDataRegister = function()
        fixture.assemble([[
            moveByte #hFF, a5
            addByte a5, d3
        ]])
            .load()
            .step(2)
            .dataRegister(3).hasValue(0xFF);
    end,

    addImmediateDataToDataRegister = function()
        fixture.assemble([[
            addByte #13, d6
        ]])
            .load()
            .step()
            .dataRegister(6).hasValue(13);
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
