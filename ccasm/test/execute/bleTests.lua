assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    branchesWhenComparisonIsLess = function()
        fixture.assemble([[
            cmpByte #hFF, d0
            ble my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    branchesWhenComparisonIsEqual = function()
        fixture.assemble([[
            cmpByte #0, d0
            ble my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    doesNotBranchWhenComparisonIsGreater = function()
        fixture.assemble([[
            cmpByte #1, d0
            ble my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    branchToImmediateData = function()
        fixture.assemble([[
            origin #2
            moveLong #h1234ABCD, d0
            moveByte #1, d0
            cmpByte #0, d0
            ble #2
            moveLong #hABCD1234, d0
        ]])
            .load()
            .step(5)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    branchToInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("ble d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("ble a0");
        end);
    end,

    branchOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("ble #h1234ABCD");
        end);
    end,

};

return testSuite;