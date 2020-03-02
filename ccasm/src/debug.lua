assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");

local screenWidth, screenHeight = term.getSize();
local baseAddress = 0;

local function drawCenteredHeader(startX, startY, label)
    local centerX = math.floor(screenWidth / 2) - math.floor(label:len() / 2);
    term.setCursorPos(centerX, startY);
    term.write(label);
    term.setCursorPos(1, startY);
    term.write("+" .. string.rep("-", centerX - 2));
    term.setCursorPos(centerX + label:len(), startY);
    term.write(string.rep("-", screenWidth - centerX - label:len()) .. "+");
end

local function draw()
    local function curX()
        return ({ term.getCursorPos() })[1];
    end
    local function curY()
        return ({ term.getCursorPos() })[2];
    end
    local function formatBytesAsHex(bytes)
        return "0x" .. string.format("%" .. (#bytes * 2) .. "X", ccasm.integer.getIntegerFromBytes(bytes)):gsub("%s", "0");
    end
    local function drawRegister(prefix, bytes)
        local info = prefix .. ": " .. formatBytesAsHex(bytes);
        if curX() + info:len() < screenWidth - 1 then
            term.write(info .. " ");
        else
            term.setCursorPos(screenWidth, curY());
            term.write("|");
            term.setCursorPos(1, curY() + 1);
            term.write("| " .. info .. " ");
        end
    end
    local function drawRegisterBlock(label, prefix, registers)
        local startX, startY = term.getCursorPos();
        drawCenteredHeader(startX, startY, label);
        term.setCursorPos(1, startY + 1);
        term.write("| ");
        for i = 0, ccasm.tableUtils.countKeys(registers) - 1 do
            drawRegister(prefix .. i, registers[i].value);
        end
        term.setCursorPos(screenWidth, curY());
        term.write("|");
    end
    local function drawStatusRegisters()
        local startX, startY = term.getCursorPos();
        drawCenteredHeader(startX, startY, "SPECIAL REGISTERS");
        term.setCursorPos(1, startY + 1);
        term.write("| ");
        drawRegister("SP", ccasm.integer.getBytesForInteger(4, ccasm.registers.getStackPointer()));
        drawRegister("SR", ccasm.integer.getBytesForInteger(4, ccasm.registers.getStatusRegister()));
        drawRegister("PC", ccasm.integer.getBytesForInteger(4, ccasm.registers.getProgramCounter()));
        term.setCursorPos(screenWidth, curY());
        term.write("|");
    end
    local function drawMemory()
        local address = baseAddress;
        local memoryWidth, memoryHeight = 0, 0;
        while curY() <= screenHeight do
            memoryHeight = memoryHeight + 1;
            term.write(formatBytesAsHex(ccasm.integer.getBytesForInteger(2, address)) .. " | ");
            while curX() + 2 <= screenWidth and address <= #ccasm.memory.bytes do
                local byte = string.format("%2X", ccasm.integer.getIntegerFromBytes(ccasm.memory.readBytes(address, 1))):gsub("%s", "0");
                term.write(byte .. " ");
                address = address + 1;
            end
            if memoryWidth == 0 then
                memoryWidth = address - baseAddress - 1;
            end
            term.setCursorPos(1, curY() + 1);
        end
        return memoryWidth, memoryHeight;
    end

    term.clear();
    term.setCursorPos(1, 1);
    drawRegisterBlock("DATA REGISTERS", "D", ccasm.registers.dataRegisters);
    term.setCursorPos(3, 1);
    term.write("[h]");
    term.setCursorPos(1, curY() + 1);
    drawRegisterBlock("ADDRESS REGISTERS", "A", ccasm.registers.addressRegisters);
    drawStatusRegisters();
    term.setCursorPos(1, curY() + 1);
    term.write("+" .. string.rep("-", screenWidth - 2) .. "+");
    term.setCursorPos(1, curY() + 1);
    return drawMemory();
end

local function drawHelp()
    term.clear();
    drawCenteredHeader(1, 1, "DEBUGGER COMMANDS");
    term.setCursorPos(1, 2);
    print(" - s: Step the ccasm.cpu.");
    print(" - k: Scroll up.");
    print(" - j: Scroll down.");
    print(" - m: Jump to address.");
    print(" - e: Exit program.");
    term.setCursorPos(1, screenHeight);
    term.write("Press any key to continue.");
    os.pullEvent("key");
end

local function tryStep()
    local success, message = pcall(ccasm.cpu.step);
    if not success then
        term.setCursorPos(1, screenHeight);
        term.clearLine();
        term.write(string.rep("!", screenWidth));
        term.setCursorPos(1, screenHeight - 1);
        term.write(message);
        sleep(5);
    end
end

local function readJumpToAddress()
    term.setCursorPos(1, screenHeight);
    term.clearLine();
    term.write(string.rep("/", screenWidth));
    term.setCursorPos(1, screenHeight - 1);
    term.clearLine();
    term.write("jump to: ");
    local addr = read();
    if addr:match("^h.+") then
        addr = tonumber(addr:match("^h(.+)"), 16);
    else
        addr = tonumber(addr);
    end
    if addr == nil or not ccasm.memory.isAddressValid(addr) then
        term.setCursorPos(1, screenHeight - 1);
        term.clearLine();
        term.write("Invalid address.");
        sleep(1);
        return baseAddress;
    end
    return addr;
end

local key;
local i = 0;
ccasm.registers.setProgramCounter(0);
repeat
    local memoryWidth, memoryHeight = draw();
    key = ({ os.pullEvent("key") })[2];
    i = i + 1;
    if key == keys.h then
        drawHelp();
    elseif key == keys.s then
        tryStep();
    elseif key == keys.k then
        baseAddress = baseAddress - memoryWidth - 1;
    elseif key == keys.j then
        baseAddress = baseAddress + memoryWidth + 1;
    elseif key == keys.m then
        -- Swallow char event following key event, so the
        -- subsequent call to read() doesn't get the 'm'.
        os.pullEvent("char"); 
        baseAddress = readJumpToAddress();
    end
    baseAddress = math.max(baseAddress, 0);
    baseAddress = math.min(baseAddress, #ccasm.memory.bytes - memoryWidth * memoryHeight);
until key == keys.e;

-- Swallow char event following key event, so
-- the shell doesn't receive the 'e'.
os.pullEvent("char");
term.clear();
term.setCursorPos(1, 1);