assert(os.loadAPI("/ccasm/src/cpu.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));

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
        fixture.assemble([[
            moveWord #256, A3
        ]])
            .load()
            .step()
            .addressRegister(3).hasValue(256);
    end,

    moveDataBetweenDataAndAddressRegisters = function()
        fixture.assemble([[
            moveWord #hFFFF, A0
            moveByte a0, a2
        ]])
            .load()
            .step(2)
            .addressRegister(0).hasValue(0xFFFF)
            .addressRegister(2).hasValue(0xFF);
    end

};

return testSuite;
