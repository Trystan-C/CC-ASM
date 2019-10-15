assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");

local fixture = cpuTestFixture;

local testSuite = {

    moveImmediateDataToDataRegister = function()
        fixture.assemble("moveByte #5, d0")
           .load()
           .step()
           .dataRegister(0).hasValue(5);
    end,

    moveDataBetweenDataRegisters = function()
        fixture.assemble([[
            moveByte #10, d1
            moveByte D1, D5
        ]])
            .load()
            .step(2)
            .dataRegister(1).hasValue(10)
            .dataRegister(5).hasValue(10);
    end,

    moveImmediateDataToAddressRegister = function()
        fixture.assemble("moveWord #256, A3")
               .load()
               .step()
               .addressRegister(3).hasValue(256);
    end,

    moveDataBetweenDataAndAddressRegisters = function()
        fixture.assemble([[
            moveWord #hFFFF, D0
            moveByte d0, a2
        ]])
               .load()
               .step(2)
               .dataRegister(0).hasValue(0xFFFF)
               .addressRegister(2).hasValue(0xFF);
    end,

    moveWordImmediateDecimalByteToDataRegister = function()
        fixture.assemble("moveWord #15, d4")
            .load()
            .step()
            .dataRegister(4).hasValue(15);
    end,

};

return testSuite;
