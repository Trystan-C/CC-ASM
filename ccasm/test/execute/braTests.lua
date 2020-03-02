assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    branchesToLabel = function()
        fixture.assemble([[
            start:
            moveByte #1, d0
            moveByte #2, d0
            bra start
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(1);
    end,

    branchesToAbsoluteAddress = function()
        fixture.assemble([[
            origin #h1000
            moveByte #1, d0
            moveByte #2, d0
            bra >h1000
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(1);
    end,

    branchToInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("bra #h1000");
            end,
            function()
                fixture.assemble("bra d0");
            end,
            function()
                fixture.assemble("bra a0");
            end,
            function()
                fixture.assemble([[
                    bra #var
                    var declareWord #h1000
                ]]);
            end,
            function()
                fixture.assemble("bra label_does_not_exist");
            end
        );
    end,

};

return testSuite;