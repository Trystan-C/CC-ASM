assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/bitUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local apiEnv = getfenv();

--STATUS REGISTER------------------------------------------
local statusRegister = 0;
STATUS_COMPARISON = 0;
STATUS_NEGATIVE = 1;
function compare(a, b)
    local diff = a - b;
    if diff == 0 then
        statusRegister = bitUtils.setOnAt(statusRegister, STATUS_COMPARISON);
    else
        statusRegister = bitUtils.setOffAt(statusRegister, STATUS_COMPARISON);
    end
    if diff < 0 then
        statusRegister = bitUtils.setOnAt(statusRegister, STATUS_NEGATIVE);
    else
        statusRegister = bitUtils.setOffAt(statusRegister, STATUS_NEGATIVE);
    end
end

function getStatusRegister()
    return statusRegister;
end

function setStatusRegister(value)
    assert(value >= 0 and value <= 255, "setStatusRegister: Expected " .. tostring(value) .. " to be 1 byte.");
    statusRegister = value;
end
--DATA/ADDRESS REGISTERS-----------------------------------
local function assertByteTableSizeIs(byteTable, size)
    local condition = #byteTable == size;
    local message = "Expected byte table to have size " .. tostring(size) .. " but was " .. tostring(#byteTable) .. ".";
    assert(condition, message);
end

local function setRegisterByte(register)
    return function(byte)
        assertByteTableSizeIs(byte, 1);
        register.value[4] = byte[1];
    end
end

local function setRegisterWord(register)
    return function(word)
        assertByteTableSizeIs(word, 2);
        register.value[3] = word[1];
        register.value[4] = word[2];
    end
end

local function setRegisterLong(register)
    return function(longWord)
        assertByteTableSizeIs(longWord, 4);
        register.value[4] = longWord[4];
        register.value[3] = longWord[3];
        register.value[2] = longWord[2];
        register.value[1] = longWord[1];
    end
end

local function getRegisterByte(register)
    return function()
        return { register.value[4] };
    end
end

local function getRegisterWord(register)
    return function()
        return { register.value[3], register.value[4] };
    end
end

local function getRegisterLong(register)
    return function()
        return { register.value[1], register.value[2], register.value[3], register.value[4] };
    end
end

local registerMetatable = {
    __index = function(register, key)
        if key == "setByte" then
            return setRegisterByte(register);
        elseif key == "getByte" then
            return getRegisterByte(register);
        elseif key == "setWord" then
            return setRegisterWord(register);
        elseif key == "getWord" then
            return getRegisterWord(register);
        elseif key == "setLong" then
            return setRegisterLong(register);
        elseif key == "getLong" then
            return getRegisterLong(register);
        else
            return register[key];
        end
    end,
};

registerWidthInBytes = 4;
dataRegisters = {};
addressRegisters = {};
for i = 0, 7 do
    dataRegisters[i] = {
        id = i;
        value = tableUtils.zeros(registerWidthInBytes);
    };
    addressRegisters[i] = {
        id = i;
        value = tableUtils.zeros(registerWidthInBytes);
    };
    setmetatable(dataRegisters[i], registerMetatable);
    setmetatable(addressRegisters[i], registerMetatable);
end
--STACK----------------------------------------------------
local STACK_START_ADDRESS = 0x7F;
STACK_SIZE_IN_BYTES = 1024;
local stackPointer = STACK_START_ADDRESS;

local function isAddressInStackRegion(address)
    return address >= STACK_START_ADDRESS and address <= STACK_START_ADDRESS + STACK_SIZE_IN_BYTES;
end

function getStackPointer()
    return stackPointer;
end

function pushStack(byteTable)
    local numBytes = tableUtils.countKeys(byteTable);
    if not isAddressInStackRegion(stackPointer + numBytes) then
        error("pushStack: Stack write exceeds max address.");
    end
    memory.writeBytes(stackPointer, byteTable);
    stackPointer = stackPointer + numBytes;
end

function popStackByte()
    assert(isAddressInStackRegion(stackPointer - 1), "popStackByte: Illegal pop below stack base.");
    local byte = memory.readBytes(stackPointer - 1, 1);
    stackPointer = stackPointer - 1;
    return byte;
end

function popStackWord()
    assert(isAddressInStackRegion(stackPointer - 2), "popStackWord: Illegal pop below stack base.");
    local word = memory.readBytes(stackPointer - 2, 2);
    stackPointer = stackPointer - 2;
    return word;
end

function popStackLong()
    assert(isAddressInStackRegion(stackPointer - 4), "popStackLong: Illegal pop below stack base.");
    local long = memory.readBytes(stackPointer - 4, 4);
    stackPointer = stackPointer - 4;
    return long;
end
--PROGRAM COUNTER------------------------------------------
local programCounter = 0;

function getProgramCounter()
    return programCounter;
end

function setProgramCounter(address)
    if memory.isAddressValid(address) then
        programCounter = address;
    else
        error("registers: Expected program counter to be a valid address, was " .. tostring(address));
    end
end
-----------------------------------------------------------
--COMMON---------------------------------------------------
function clear()
    for i = 0, 7 do
        dataRegisters[i].setLong(tableUtils.zeros(registerWidthInBytes));
        addressRegisters[i].setLong(tableUtils.zeros(registerWidthInBytes));
    end
    statusRegister = 0;
    stackPointer = STACK_START_ADDRESS;
end
-----------------------------------------------------------