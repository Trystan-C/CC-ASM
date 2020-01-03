assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    stackDataRegisters = function()
        fixture.assemble([[
            moveLong #h1234ABCD, d2
            moveLong #hABCD1234, d5
            push d0-5
            moveLong #hABCD1234, d2
            moveLong #h1234ABCD, d5
            pop d0-5
        ]])
            .load()
            .step(6)
            .dataRegister(2).hasValue(0x1234ABCD)
            .dataRegister(5).hasValue(0xABCD1234);
    end,

    stackAddressRegisters = function()
        fixture.assemble([[
            moveLong #h1234ABCD, A0
            moveLong #hABCD1234, a6
            push a0-6
            moveLong #hABCD1234, a0
            moveLong #h1234ABCD, A6
            pop A0-6
        ]])
            .load()
            .step(6)
            .addressRegister(0).hasValue(0x1234ABCD)
            .addressRegister(6).hasValue(0xABCD1234);
    end,

    stackRegisterRange = function()
        fixture.assemble([[
            moveLong #hABCD1234, d0
            moveLong #h1234ABCD, d1
            moveLong #hABCD1234, a3
            moveLong #h1234ABCD, a4
            push d0-1/a3-4
            moveLong #h56781234, d0
            moveLong #h12345678, d1
            moveLong #h56781234, a0
            moveLong #h12345678, a1
            pop d0-1/a3-4
        ]])
            .load()
            .step(10)
            .dataRegister(0).hasValue(0xABCD1234)
            .dataRegister(1).hasValue(0x1234ABCD)
            .addressRegister(3).hasValue(0xABCD1234)
            .addressRegister(4).hasValue(0x1234ABCD);
    end,

    stackSingleDataRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, D5
            push d5
            moveLong #hABCD1234, d5
            pop D5
        ]])
            .load()
            .step(4)
            .dataRegister(5).hasValue(0x1234ABCD);
    end,

    stackSingleAddressRegister = function()
        fixture.assemble([[
            moveLong #h1234ABCD, a6
            push A6
            moveLong #hABCD1234, a6
            pop A6
        ]])
            .load()
            .step(4)
            .addressRegister(6).hasValue(0x1234ABCD);
    end,

    stackMalformedDataRegisterRangeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("push d1-");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop d1-");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push d0-d");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop d0-d");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push d0-d2");
        end)
        expect.errorToBeThrown(function()
            fixture.assemble("pop d0-d2");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push d0-23");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop d0-23");
        end);
    end,

    stackMalformedAddressRegisterRangeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("push a1-");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop a1-");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push a0-a");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop a0-a");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push a0-a2");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop a0-a2");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push a0-23");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop a0-23");
        end);
    end,

    stackMalformedRegisterRangeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("push d0-1/a0-");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop d0-1/a0-");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push d0-1/a0-23");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop d0-1/a0-23");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("push d0-9/a0-5");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("pop d0-9/a0-5");
        end);
    end,

};

return testSuite;