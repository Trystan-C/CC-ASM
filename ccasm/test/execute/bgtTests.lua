assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    branchesWhenComparisonIsGreater = function()
        fixture.assemble([[
            origin #h1000
            moveLong #h1234ABCD, d0
            moveByte #1, d0
            cmpByte #2, d0
            bgt #h1000
            moveLong #hABCD1234, d0
        ]])
            .load()
            .step(5)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    doesNotBranchWhenComparisonIsEqual = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte #1, d0
            bgt my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    doesNotBranchWhenComparisonIsLess = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte #0, d0
            bgt my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    branchAddressTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("bgt #h1234ABCD");
        end);
    end,

    branchToInvalidOperandThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("bgt d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("bgt a0");
        end);
    end,

};

return testSuite;