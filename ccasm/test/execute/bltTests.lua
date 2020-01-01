assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    branchesWhenComparisonIsLessThan = function()
        fixture.assemble([[
            moveByte #2, d0
            cmpByte #1, d0
            blt my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    doesNotBranchWhenComparisonIsEqual = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte #1, d0
            blt my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    doesNotBranchWhenComparisonIsGreater = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte #2, d0
            blt my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    branchToImmediateData = function()
        fixture.assemble([[
            origin #10
            moveLong #hABCD1234, d0
            moveByte #1, d0
            cmpByte #0, d0
            blt #10
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(5)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    branchToInvalidOperandTypeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("blt d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("blt a0");
        end);
    end,

    branchOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("blt #h1234ABCD");
        end);
    end,

};

return testSuite;