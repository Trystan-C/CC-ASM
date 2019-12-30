assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    branchesWhenComparisonIsNotEqual = function()
        fixture.assemble([[
            moveByte #1, d0
            cmpByte #2, d0
            bne my_branch
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
            bne my_branch
            moveLong #hABCD1234, d0
            my_branch:
            moveLong #h1234ABCD, d0
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xABCD1234);
    end,

    branchToAbsoluteAddress = function()
        fixture.assemble([[
            origin #4
            moveLong #h1234ABCD, d0
            moveLong #hABCD1234, d0
            moveByte #1, d0
            cmpByte #2, d0
            bne #4
            moveLong #h4321CDBA, d0
        ]])
            .load()
            .programCounterIsAt(4)
            .step(6)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

    branchToInvalidOperandTypeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("beq d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("beq a0");
        end);
    end,
    
};

return testSuite;