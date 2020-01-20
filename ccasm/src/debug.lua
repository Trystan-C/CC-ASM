assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");

local baseAddress = 0;

local function draw()
    local screenWidth, screenHeight = term.getSize();
    local function curX()
        return ({ term.getCursorPos() })[1];
    end
    local function curY()
        return ({ term.getCursorPos() })[2];
    end
    local function formatBytesAsHex(bytes)
        return "0x" .. string.format("%" .. (#bytes * 2) .. "X", integer.getIntegerFromBytes(bytes)):gsub("%s", "0");
    end
    local function drawCenteredHeader(startX, startY, label)
        local centerX = math.floor(screenWidth / 2) - math.floor(label:len() / 2);
        term.setCursorPos(centerX, startY);
        term.write(label);
        term.setCursorPos(1, startY);
        term.write("+" .. string.rep("-", centerX - 2));
        term.setCursorPos(centerX + label:len(), startY);
        term.write(string.rep("-", screenWidth - centerX - label:len()) .. "+");
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
        for i = 0, tableUtils.countKeys(registers) - 1 do
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
        drawRegister("SP", integer.getBytesForInteger(4, registers.getStackPointer()));
        drawRegister("SR", integer.getBytesForInteger(4, registers.getStatusRegister()));
        drawRegister("PC", integer.getBytesForInteger(4, registers.getProgramCounter()));
        term.setCursorPos(screenWidth, curY());
        term.write("|");
    end
    local function drawMemory()
        local address = baseAddress;
        local memoryWidth, memoryHeight = 0, 0;
        while curY() <= screenHeight do
            memoryHeight = memoryHeight + 1;
            term.write(formatBytesAsHex(integer.getBytesForInteger(2, address)) .. " | ");
            while curX() + 2 <= screenWidth and address <= #memory.bytes do
                local byte = string.format("%2X", integer.getIntegerFromBytes(memory.readBytes(address, 1))):gsub("%s", "0");
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
    drawRegisterBlock("DATA REGISTERS", "D", registers.dataRegisters);
    term.setCursorPos(1, curY() + 1);
    drawRegisterBlock("ADDRESS REGISTERS", "A", registers.addressRegisters);
    drawStatusRegisters();
    term.setCursorPos(1, curY() + 1);
    term.write("+" .. string.rep("-", screenWidth - 2) .. "+");
    term.setCursorPos(1, curY() + 1);
    return drawMemory();
end

local key;
local i = 0;
registers.setProgramCounter(0);
repeat
    local memoryWidth, memoryHeight = draw();
    key = ({ os.pullEvent("char") })[2];
    i = i + 1;
    if key == 's' then
        cpu.step();
    elseif key == 'k' and baseAddress - memoryWidth >= 0 then
        baseAddress = baseAddress - memoryWidth - 1;
    elseif key == 'j' and baseAddress + memoryWidth * memoryHeight <= #memory.bytes then
        baseAddress = baseAddress + memoryWidth + 1;
    end
until key == 'e';

term.clear();
term.setCursorPos(1, 1);