assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/bitUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local apiEnv = getfenv();
--NOP-------------------------------------------------------------------
apiEnv.nop = {
    byteValue = 0,
    numOperands = 0,
    execute = function()
    end,
};
--MOVE------------------------------------------------------------------
local function move(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            if operand.definition ~= operandTypes.symbolicAddress and
            operand.definition ~= operandTypes.absoluteSymbolicAddress and
            operand.definition ~= operandTypes.absoluteAddress then
                assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
            end
        end,
        verifyAll = function(from, to)
            assert(
                not (from.definition == operandTypes.symbolicAddress and to.definition == operandTypes.symbolicAddress) and
                not (from.definition == operandTypes.symbolicAddress and to.definition == operandTypes.absoluteAddress) and
                not (from.definition == operandTypes.symbolicAddress and to.definition == operandTypes.indirectAddress) and
                not (from.definition == operandTypes.absoluteAddress and to.definition == operandTypes.symbolicAddress) and
                not (from.definition == operandTypes.absoluteAddress and to.definition == operandTypes.absoluteAddress) and
                not (from.definition == operandTypes.absoluteAddress and to.definition == operandTypes.indirectAddress) and
                not (from.definition == operandTypes.indirectAddress and to.definition == operandTypes.symbolicAddress) and
                not (from.definition == operandTypes.indirectAddress and to.definition == operandTypes.absoluteAddress) and
                not (from.definition == operandTypes.indirectAddress and to.definition == operandTypes.indirectAddress),
                name .. ": Cannot move directly between absolute, symbolic, or indirect addresses."
            );
        end,
        execute = function(from, to)
            operandUtils[sizeDescriptor](to).set(operandUtils[sizeDescriptor](from).get());
        end,
    };
end
move(1, "moveByte", "byte", 1);
move(2, "moveWord", "word", 2);
move(3, "moveLong", "long", 4);
--ADDITION--------------------------------------------------------------
local function add(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
        end,
        verifyAll = function(from, to)
            assert(
                from.definition == operandTypes.dataRegister or
                from.definition == operandTypes.immediateData,
                name .. ": source must be data register."
            );
            assert(
                to.definition == operandTypes.dataRegister,
                name .. ": destination must be a data register."
            );
        end,
        execute = function(from, to)
            local sum = integer.addBytes(
                operandUtils[sizeDescriptor](from).get(),
                operandUtils[sizeDescriptor](to).get()
            );
            operandUtils[sizeDescriptor](to).set(tableUtils.fitToSize(sum, sizeInBytes));
        end,
    };
end
add(4, "addByte", "byte", 1);
add(5, "addWord", "word", 2);
add(6, "addLong", "long", 4);
--SUBTRACTION-----------------------------------------------------------
local function sub(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
        end,
        verifyAll = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                name .. ": Source must be immediate data or data reigster."
            );
            assert(to.definition == operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(from, to)
            local difference = integer.subtractBytes(
                operandUtils[sizeDescriptor](to).get(),
                operandUtils[sizeDescriptor](from).get()
            );
            operandUtils[sizeDescriptor](to).set(tableUtils.fitToSize(difference, sizeInBytes));
        end,
    };
end
sub(7, "subByte", "byte", 1);
sub(8, "subWord", "word", 2);
sub(9, "subLong", "long", 4);
--MULTIPLICATION--------------------------------------------------------
local function mul(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
        end,
        verifyAll = function(from, to)
            assert(
                from.definition == operandTypes.dataRegister or
                from.definition == operandTypes.immediateData,
                name .. ": Source must be data register or immediate data."
            );
            assert(to.definition == operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(from, to)
            local product = integer.multiplyBytes(
                operandUtils[sizeDescriptor](from).get(),
                operandUtils[sizeDescriptor](to).get()
            );
            operandUtils[sizeDescriptor](to).set(tableUtils.fitToSize(product, sizeInBytes));
        end,
    };
end
mul(10, "mulByte", "byte", 1);
mul(11, "mulWord", "word", 2);
mul(12, "mulLong", "long", 4);
--DIVISION-------------------------------------------------
local function div(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
        end,
        verifyAll = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                name .. ": Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(from, to)
            local quotient = integer.divideBytes(
                operandUtils[sizeDescriptor](from).get(),
                operandUtils[sizeDescriptor](to).get()
            );
            operandUtils[sizeDescriptor](to).set(tableUtils.fitToSize(quotient, sizeInBytes));
        end,
    };
end
div(13, "divByte", "byte", 1);
div(14, "divWord", "word", 2);
div(15, "divLong", "long", 4);
--COMPARISON------------------------------------------------------------
local function cmp(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
        end,
        verifyAll = function(left, right)
            assert(
                left.definition == operandTypes.dataRegister or
                left.definition == operandTypes.immediateData,
                name .. ": Left operand must be immediate data or data register."
            );
            assert(
                right.definition == operandTypes.immediateData or
                right.definition == operandTypes.dataRegister,
                name .. "cmpByte: Right operand must be immediate data or data register."
            );
        end,
        execute = function(left, right)
            registers.compare(
                integer.getSignedIntegerFromBytes(operandUtils[sizeDescriptor](left).get()),
                integer.getSignedIntegerFromBytes(operandUtils[sizeDescriptor](right).get())
            );
        end,
    };
end
cmp(16, "cmpByte", "byte", 1);
cmp(17, "cmpWord", "word", 2);
cmp(18, "cmpLong", "long", 4);
--BRANCHING-------------------------------------------------------------
apiEnv.beq = {
    byteValue = 19,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "beq: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "beq: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 1 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bne = {
    byteValue = 20,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bne: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "bne: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 0 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.blt = {
    byteValue = 21,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "blt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "blt: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 0 and 
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 1 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.ble = {
    byteValue = 22,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "blt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "ble: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 1 or
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 1 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bgt = {
    byteValue = 23,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bgt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "bgt: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 0 and
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 0 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bge = {
    byteValue = 24,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bge: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "bge: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 1 or
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 0 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
--SUBROUTINES----------------------------------------------
apiEnv.bsr = {
    byteValue = 25,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == operandTypes.symbolicAddress, "bsr: Operand must be symbolic address.");
    end,
    execute = function(operand)
        -- Program counter will be at the next instruction, since cpu will read the instruction and operand before executing.
        registers.pushStack(integer.getBytesForInteger(2, registers.getProgramCounter()));
        registers.setProgramCounter(operandUtils.absoluteAddress(operand));
    end,
};
apiEnv.ret = {
    byteValue = 26,
    numOperands = 0,
    execute = function()
        registers.setProgramCounter(integer.getIntegerFromBytes(registers.popStackWord()));
    end,
};
--STACK----------------------------------------------------
apiEnv.push = {
    byteValue = 27,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == operandTypes.registerRange or
            operand.definition == operandTypes.dataRegister or
            operand.definition == operandTypes.addressRegister,
            "push: Operand must be a data/address register or register range.");
    end,
    execute = function(operand)
        if operand.definition == operandTypes.registerRange then
            local dataRegisterIds = operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[1]);
            for _, dataRegisterId in ipairs(dataRegisterIds) do
                registers.pushStack(registers.dataRegisters[dataRegisterId].value);
            end

            local addressRegisterIds = operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[2]);
            for _, addressRegisterId in ipairs(addressRegisterIds) do
                registers.pushStack(registers.addressRegisters[addressRegisterId].value);
            end
        else
            registers.pushStack(operandUtils.long(operand).get());
        end
    end,
};
apiEnv.pop = {
    byteValue = 28,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == operandTypes.registerRange or
            operand.definition == operandTypes.dataRegister or
            operand.definition == operandTypes.addressRegister,
            "pop: Operand must be data/address register or register range."
        );
    end,
    execute = function(operand)
        if operand.definition == operandTypes.registerRange then
            local dataRegisterIds = operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[1]);
            for i = #dataRegisterIds, 1, -1 do
                registers.dataRegisters[dataRegisterIds[i]].setLong(registers.popStackLong());
            end

            local addressRegisterIds = operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[2]);
            for i = #addressRegisterIds, 1, -1 do
                registers.addressRegisters[addressRegisterIds[i]].setLong(registers.popStackLong());
            end
        else
            operandUtils.long(operand).set(registers.popStackLong());
        end
    end,
}
--SHIFT----------------------------------------------------
apiEnv.lshiftByte = {
    byteValue = 29,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == operandTypes.dataRegister or
            operand.definition == operandTypes.addressRegister,
            "lshiftByte: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        operandUtils.long(operand).set(
            integer.leftShiftBytes(operandUtils.long(operand).get(), 1)
        );
    end,
};
apiEnv.lshiftWord = {
    byteValue = 30,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == operandTypes.dataRegister or
            operand.definition == operandTypes.addressRegister,
            "lshiftWord: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        operandUtils.long(operand).set(
            integer.leftShiftBytes(operandUtils.long(operand).get(), 2)
        );
    end,
};
apiEnv.rshiftByte = {
    byteValue = 31,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == operandTypes.dataRegister or
            operand.definition == operandTypes.addressRegister,
            "rshiftByte: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        operandUtils.long(operand).set(
            integer.rightShiftBytes(operandUtils.long(operand).get(), 1)
        );
    end,
};
apiEnv.rshiftWord = {
    byteValue = 32,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == operandTypes.dataRegister or
            operand.definition == operandTypes.addressRegister,
            "rshiftWord: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        operandUtils.long(operand).set(
            integer.rightShiftBytes(operandUtils.long(operand).get(), 2)
        );
    end,
};
--OR-------------------------------------------------------
-- _or, since 'or' is a keyword.
local function _or(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
            assert(
                operand.definition == operandTypes.dataRegister or
                operand.definition == operandTypes.immediateData,
                name .. ": Operand must be data register or immediate data."
            );
        end,
        verifyAll = function(source, destination)
            assert(destination.definition == operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(source, destination)
            operandUtils[sizeDescriptor](destination).set(
                integer.orBytes(
                    operandUtils[sizeDescriptor](source).get(),
                    operandUtils[sizeDescriptor](destination).get()
                )
            );
        end,
    };
end
_or(33, "orByte", "byte", 1);
_or(34, "orWord", "word", 2);
_or(35, "orLong", "long", 4);
--AND------------------------------------------------------
-- _and, since 'and' is a keyword.
local function _and(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
            assert(
                operand.definition == operandTypes.dataRegister or
                operand.definition == operandTypes.immediateData,
                name .. ": Operand must be data register or immediate data."
            );
        end,
        verifyAll = function(source, destination)
            assert(destination.definition == operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(source, destination)
            operandUtils[sizeDescriptor](destination).set(
                integer.andBytes(
                    operandUtils[sizeDescriptor](source).get(),
                    operandUtils[sizeDescriptor](destination).get()
                )
            );
        end,
    };
end
_and(36, "andByte", "byte", 1);
_and(37, "andWord", "word", 2);
_and(38, "andLong", "long", 4);
--XOR------------------------------------------------------
local function xor(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, name .. ": Operand must be at most " .. sizeInBytes .. " byte(s).");
            assert(
                operand.definition == operandTypes.immediateData or
                operand.definition == operandTypes.dataRegister,
                name .. ": Operand must be immediate data or data register."
            );
        end,
        verifyAll = function(source, destination)
            assert(destination.definition == operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(source, destination)
            operandUtils[sizeDescriptor](destination).set(
                integer.xorBytes(
                    operandUtils[sizeDescriptor](source).get(),
                    operandUtils[sizeDescriptor](destination).get()
                )
            );
        end,
    };
end
xor(39, "xorByte", "byte", 1);
xor(40, "xorWord", "word", 2);
xor(41, "xorLong", "long", 4);
--NOT------------------------------------------------------
-- _not, since 'not' is a keyword.
local function _not(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 1,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= 1, name .. ": Operand must be at most " .. sizeInBytes .. " byte(s).");
            assert(operand.definition == operandTypes.dataRegister, name .. ": Operand must be data register.");
        end,
        execute = function(operand)
            operandUtils[sizeDescriptor](operand).set(
                integer.notBytes(
                    operandUtils[sizeDescriptor](operand).get()
                )
            );
        end,
    };
end
_not(42, "notByte", "byte", 1);
_not(43, "notWord", "word", 2);
_not(44, "notLong", "long", 4);
--TRAP-----------------------------------------------------
apiEnv.trap = {
    byteValue = 45,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == operandTypes.immediateData, "trap: Operand must be immediate data.");
        assert(operand.sizeInBytes == 1, "trap: Operand must be at most 1 byte.");
    end,
    execute = function(operand)
        local byte = (operandUtils.byte(operand).get())[1];
        -- getTerminalDimensions
        if byte == 0 then
            local width, height = term.getSize();
            registers.dataRegisters[6].setLong(
                tableUtils.fitToSize(integer.getBytesForInteger(width), 4)
            );
            registers.dataRegisters[7].setLong(
                tableUtils.fitToSize(integer.getBytesForInteger(height), 4)
            );
        -- getCursorPosition
        elseif byte == 1 then
            local cursorX, cursorY = term.getCursorPos();
            registers.dataRegisters[6].setLong(
                tableUtils.fitToSize(integer.getBytesForInteger(cursorX), 4)
            );
            registers.dataRegisters[7].setLong(
                tableUtils.fitToSize(integer.getBytesForInteger(cursorY), 4)
            );
        -- setCursorPosition
        elseif byte == 2 then
            term.setCursorPos(
                integer.getSignedIntegerFromBytes(
                    registers.dataRegisters[0].getLong()
                ),
                integer.getSignedIntegerFromBytes(
                    registers.dataRegisters[1].getLong()
                )
            );
        -- writeString
        elseif byte == 3 then
            local absoluteAddress = integer.getIntegerFromBytes(registers.addressRegisters[0].getWord());
            local str = "";
            local offset = 0;
            local limit = 1024;
            while offset <= limit do
                local byte = (memory.readBytes(absoluteAddress + offset, 1))[1];
                offset = offset + 1;
                if byte == 0 then
                    break;
                else
                    str = str .. string.char(byte);
                end
            end
            if offset >= limit then
                error("trap(#3): Read " .. limit .. " bytes before stopping string read.");
            end
            term.write(str);
        -- readString
        elseif byte == 4 then
            local str = read();
            local strBytes = {};
            for char in str:gmatch(".") do
                table.insert(strBytes, string.byte(char));
            end
            table.insert(strBytes, 0); -- Append null-terminator.
            memory.writeBytes(
                integer.getIntegerFromBytes(registers.addressRegisters[0].getWord()),
                strBytes
            );
        elseif byte == 5 then
            os.shutdown();
        elseif byte == 6 then
            os.reboot();
        else
            error("trap: Unsupporetd trap-byte(" .. tostring(byte) .. ").");
        end
    end,
};
--DEFINITION MAP-------------------------------------------
local function isInstructionDefinition(definition)
    return type(definition) == "table" and
            definition.byteValue ~= nil and
            definition.numOperands ~= nil;
end

local function throwInstructionRedefinitionError(byteValue)
    local message = "Instruction byte value " .. tostring(byteValue) .. " cannot be shared.";
    error(message);
end

local byteToDefinitionMap = {};
for name, definition in pairs(getfenv()) do
    if isInstructionDefinition(definition) then
        if byteToDefinitionMap[definition.byteValue] ~= nil then
            throwInstructionRedefinitionError(definition.byteValue);
        else
            byteToDefinitionMap[definition.byteValue] = definition;
        end
    end
end

function definitionFromByte(instructionByte)
    return byteToDefinitionMap[instructionByte];
end