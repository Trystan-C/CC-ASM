assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    getTerminalDimensions = function()
        local width, height = term.getSize();
        fixture.assemble("trap #0")
            .load()
            .step()
            .dataRegister(6).hasValue(width)
            .dataRegister(7).hasValue(height);
    end,

    getCursorPosition = function()
        local cursorX, cursorY = term.getCursorPos();
        fixture.assemble("trap #1")
            .load()
            .step()
            .dataRegister(6).hasValue(cursorX)
            .dataRegister(7).hasValue(cursorY);
    end,

    setCursorPosition = function()
        local originalX, originalY = term.getCursorPos();
        fixture.assemble([[
            moveByte #37, d0
            moveByte #42, d1
            trap #2
        ]])
            .load()
            .step(3);
        local newX, newY = term.getCursorPos();
        expect.value(newX).toEqual(37);
        expect.value(newY).toEqual(42);
        term.setCursorPos(originalX, originalY);
    end,

    trapUnsupportedValueThrowsError = function()
        expect.errorsToBeThrown(function()
            fixture.assemble("trap #hFF")
                .load()
                .step();
        end);
    end,

    trapOperandTooLargeThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("trap #h1234");
            end,
            function()
                fixture.assemble("trap #h1234ABCD");
            end
        );
    end,

    trapInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("trap d0");
            end,
            function()
                fixture.assemble("trap a0");
            end,
            function()
                fixture.assemble([[
                    trap var
                    var declareByte #0
                ]]);
            end
        );
    end,

};

return testSuite;