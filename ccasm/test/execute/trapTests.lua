assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
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

    clearScreen = function()
        local cleared = false;
        local originalTerm = _G.term;
        local mockTerm = {
            clear = function()
                cleared = true;
            end,
        };
        setmetatable(mockTerm, { __index = originalTerm });
        _G.term = mockTerm;

        local result, message = pcall(function()
            fixture.assemble("trap #3")
                .load()
                .step();
        end);
        if not result then
            ccasm.logger.info("trapTests.clearScreen: Error during execution: %%", message);
        end
        
        _G.term = originalTerm;
        expect.value(cleared).toEqual(true);
    end,

    clearLine = function()
        local cleared = false;
        local originalTerm = _G.term;
        local mockTerm = {
            clearLine = function()
                cleared = true;
            end,
        };
        setmetatable(mockTerm, { __index = originalTerm });
        _G.term = mockTerm;

        local result, message = pcall(function()
            fixture.assemble("trap #4")
                .load()
                .step();
        end);
        if not result then
            ccasm.logger.info("trapTests.clearLine: Error during execution: %%", message);
        end

        _G.term = originalTerm;
        expect.value(cleared).toEqual(true);
    end,

    writeString = function()
        local originalTerm = _G.term;
        local writtenStr = "set me";
        local mockTerm = {
            write = function(str)
                writtenStr = str;
            end,
        };

        setmetatable(mockTerm, { __index = originalTerm });
        _G.term = mockTerm;
        local result, message = pcall(function()
            fixture.assemble([[
                moveLong #str, a0
                trap #5
                str declareString "test"
            ]])
                .load()
                .step(2);
        end);
        if not result then
            ccasm.logger.info("trapTests.writeString: Error during execution: %%", message);
        end
        _G.term = originalTerm;

        expect.value(writtenStr).toEqual("test");
    end,

    readString = function()
        local originalRead = _G.read;
        _G.read = function()
            return "abc";
        end

        local result, message = pcall(function()
            fixture.assemble([[
                moveWord #h1000, a0
                trap #6
                moveLong >h1000, d0
            ]])
                .load()
                .step(3)
                .dataRegister(0).hasValue(0x61626300);
        end);
        _G.read = originalRead;
        if not result then
            error(message);
        end
    end,

    getStringLength = function()
        fixture.assemble([[
            moveWord #str, a0
            trap #7
            str declareString "12345"
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(5);
    end,

    shutdown = function()
        local oldShutdown = _G.os.shutdown;
        local called = false;
        _G.os.shutdown = function()
            called = true;
        end

        local result, message = pcall(function()
            fixture.assemble("trap #8")
                .load()
                .step();
        end);
        _G.os.shutdown = oldShutdown;
        if not result then
            error(message);
        end
    end,

    reboot = function()
        local oldReboot = _G.os.reboot;
        local called = false;
        _G.os.reboot = function()
            called = true;
        end

        local result, message = pcall(function()
            fixture.assemble("trap #9")
                .load()
                .step();
        end);
        _G.os.reboot = oldReboot;
        if not result then
            error(message);
        end
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