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
            if operand.definition ~= ccasm.operandTypes.symbolicAddress and
            operand.definition ~= ccasm.operandTypes.absoluteSymbolicAddress and
            operand.definition ~= ccasm.operandTypes.absoluteAddress then
                assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
            end
        end,
        verifyAll = function(from, to)
            assert(
                not (from.definition == ccasm.operandTypes.symbolicAddress and to.definition == ccasm.operandTypes.symbolicAddress) and
                not (from.definition == ccasm.operandTypes.symbolicAddress and to.definition == ccasm.operandTypes.absoluteAddress) and
                not (from.definition == ccasm.operandTypes.symbolicAddress and to.definition == ccasm.operandTypes.indirectAddress) and
                not (from.definition == ccasm.operandTypes.absoluteAddress and to.definition == ccasm.operandTypes.symbolicAddress) and
                not (from.definition == ccasm.operandTypes.absoluteAddress and to.definition == ccasm.operandTypes.absoluteAddress) and
                not (from.definition == ccasm.operandTypes.absoluteAddress and to.definition == ccasm.operandTypes.indirectAddress) and
                not (from.definition == ccasm.operandTypes.indirectAddress and to.definition == ccasm.operandTypes.symbolicAddress) and
                not (from.definition == ccasm.operandTypes.indirectAddress and to.definition == ccasm.operandTypes.absoluteAddress) and
                not (from.definition == ccasm.operandTypes.indirectAddress and to.definition == ccasm.operandTypes.indirectAddress),
                name .. ": Cannot move directly between absolute, symbolic, or indirect addresses."
            );
        end,
        execute = function(from, to)
            ccasm.operandUtils[sizeDescriptor](to).set(ccasm.operandUtils[sizeDescriptor](from).get());
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
                from.definition == ccasm.operandTypes.dataRegister or
                from.definition == ccasm.operandTypes.immediateData,
                name .. ": source must be data register."
            );
            assert(
                to.definition == ccasm.operandTypes.dataRegister,
                name .. ": destination must be a data register."
            );
        end,
        execute = function(from, to)
            local sum = ccasm.integer.addBytes(
                ccasm.operandUtils[sizeDescriptor](from).get(),
                ccasm.operandUtils[sizeDescriptor](to).get()
            );
            ccasm.operandUtils[sizeDescriptor](to).set(ccasm.tableUtils.fitToSize(sum, sizeInBytes));
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
                from.definition == ccasm.operandTypes.immediateData or
                from.definition == ccasm.operandTypes.dataRegister,
                name .. ": Source must be immediate data or data reigster."
            );
            assert(to.definition == ccasm.operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(from, to)
            local difference = ccasm.integer.subtractBytes(
                ccasm.operandUtils[sizeDescriptor](to).get(),
                ccasm.operandUtils[sizeDescriptor](from).get()
            );
            ccasm.operandUtils[sizeDescriptor](to).set(ccasm.tableUtils.fitToSize(difference, sizeInBytes));
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
                from.definition == ccasm.operandTypes.dataRegister or
                from.definition == ccasm.operandTypes.immediateData,
                name .. ": Source must be data register or immediate data."
            );
            assert(to.definition == ccasm.operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(from, to)
            local product = ccasm.integer.multiplyBytes(
                ccasm.operandUtils[sizeDescriptor](from).get(),
                ccasm.operandUtils[sizeDescriptor](to).get()
            );
            ccasm.operandUtils[sizeDescriptor](to).set(ccasm.tableUtils.fitToSize(product, sizeInBytes));
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
                from.definition == ccasm.operandTypes.immediateData or
                from.definition == ccasm.operandTypes.dataRegister,
                name .. ": Source must be immediate data or data register."
            );
            assert(to.definition == ccasm.operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(from, to)
            local quotient = ccasm.integer.divideBytes(
                ccasm.operandUtils[sizeDescriptor](from).get(),
                ccasm.operandUtils[sizeDescriptor](to).get()
            );
            ccasm.operandUtils[sizeDescriptor](to).set(ccasm.tableUtils.fitToSize(quotient, sizeInBytes));
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
                left.definition == ccasm.operandTypes.dataRegister or
                left.definition == ccasm.operandTypes.immediateData,
                name .. ": Left operand must be immediate data or data register."
            );
            assert(
                right.definition == ccasm.operandTypes.immediateData or
                right.definition == ccasm.operandTypes.dataRegister,
                name .. "cmpByte: Right operand must be immediate data or data register."
            );
        end,
        execute = function(left, right)
            ccasm.registers.compare(
                ccasm.integer.getSignedIntegerFromBytes(ccasm.operandUtils[sizeDescriptor](left).get()),
                ccasm.integer.getSignedIntegerFromBytes(ccasm.operandUtils[sizeDescriptor](right).get())
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
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.immediateData,
            "beq: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON) == 1 then
            ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bne = {
    byteValue = 20,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bne: Operand must be at most 2 bytes.");
        assert(
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.immediateData,
            "bne: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON) == 0 then
            ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.blt = {
    byteValue = 21,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "blt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.immediateData,
            "blt: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON) == 0 and 
        ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_NEGATIVE) == 1 then
            ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.ble = {
    byteValue = 22,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "blt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.immediateData,
            "ble: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON) == 1 or
        ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_NEGATIVE) == 1 then
            ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bgt = {
    byteValue = 23,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bgt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.immediateData,
            "bgt: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON) == 0 and
        ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_NEGATIVE) == 0 then
            ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bge = {
    byteValue = 24,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bge: Operand must be at most 2 bytes.");
        assert(
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.immediateData,
            "bge: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON) == 1 or
        ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_NEGATIVE) == 0 then
            ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bra = {
    byteValue = 25,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bra: Operand must be at most 2 bytes.");
        assert(
            operand.definition == ccasm.operandTypes.symbolicAddress or
            operand.definition == ccasm.operandTypes.absoluteAddress,
            "bra: Operand must be symbolic or absolute address."
        );
    end,
    execute = function(operand)
        ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
    end
};
--SUBROUTINES----------------------------------------------
apiEnv.bsr = {
    byteValue = 26,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.symbolicAddress, "bsr: Operand must be symbolic address.");
    end,
    execute = function(operand)
        -- Program counter will be at the next instruction, since cpu will read the instruction and operand before executing.
        ccasm.registers.pushStack(ccasm.integer.getBytesForInteger(2, ccasm.registers.getProgramCounter()));
        ccasm.registers.setProgramCounter(ccasm.operandUtils.absoluteAddress(operand));
    end,
};
apiEnv.ret = {
    byteValue = 27,
    numOperands = 0,
    execute = function()
        ccasm.registers.setProgramCounter(ccasm.integer.getIntegerFromBytes(ccasm.registers.popStackWord()));
    end,
};
--STACK----------------------------------------------------
apiEnv.push = {
    byteValue = 28,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == ccasm.operandTypes.registerRange or
            operand.definition == ccasm.operandTypes.dataRegister or
            operand.definition == ccasm.operandTypes.addressRegister,
            "push: Operand must be a data/address register or register range.");
    end,
    execute = function(operand)
        if operand.definition == ccasm.operandTypes.registerRange then
            local dataRegisterIds = ccasm.operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[1]);
            for _, dataRegisterId in ipairs(dataRegisterIds) do
                ccasm.registers.pushStack(ccasm.registers.dataRegisters[dataRegisterId].value);
            end

            local addressRegisterIds = ccasm.operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[2]);
            for _, addressRegisterId in ipairs(addressRegisterIds) do
                ccasm.registers.pushStack(ccasm.registers.addressRegisters[addressRegisterId].value);
            end
        else
            ccasm.registers.pushStack(ccasm.operandUtils.long(operand).get());
        end
    end,
};
apiEnv.pop = {
    byteValue = 29,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == ccasm.operandTypes.registerRange or
            operand.definition == ccasm.operandTypes.dataRegister or
            operand.definition == ccasm.operandTypes.addressRegister,
            "pop: Operand must be data/address register or register range."
        );
    end,
    execute = function(operand)
        if operand.definition == ccasm.operandTypes.registerRange then
            local dataRegisterIds = ccasm.operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[1]);
            for i = #dataRegisterIds, 1, -1 do
                ccasm.registers.dataRegisters[dataRegisterIds[i]].setLong(ccasm.registers.popStackLong());
            end

            local addressRegisterIds = ccasm.operandTypes.registerRange.registerIdsFromByte(operand.valueBytes[2]);
            for i = #addressRegisterIds, 1, -1 do
                ccasm.registers.addressRegisters[addressRegisterIds[i]].setLong(ccasm.registers.popStackLong());
            end
        else
            ccasm.operandUtils.long(operand).set(ccasm.registers.popStackLong());
        end
    end,
}
--SHIFT----------------------------------------------------
apiEnv.lshiftByte = {
    byteValue = 30,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == ccasm.operandTypes.dataRegister or
            operand.definition == ccasm.operandTypes.addressRegister,
            "lshiftByte: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        ccasm.operandUtils.long(operand).set(
            ccasm.integer.leftShiftBytes(ccasm.operandUtils.long(operand).get(), 1)
        );
    end,
};
apiEnv.lshiftWord = {
    byteValue = 31,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == ccasm.operandTypes.dataRegister or
            operand.definition == ccasm.operandTypes.addressRegister,
            "lshiftWord: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        ccasm.operandUtils.long(operand).set(
            ccasm.integer.leftShiftBytes(ccasm.operandUtils.long(operand).get(), 2)
        );
    end,
};
apiEnv.rshiftByte = {
    byteValue = 32,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == ccasm.operandTypes.dataRegister or
            operand.definition == ccasm.operandTypes.addressRegister,
            "rshiftByte: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        ccasm.operandUtils.long(operand).set(
            ccasm.integer.rightShiftBytes(ccasm.operandUtils.long(operand).get(), 1)
        );
    end,
};
apiEnv.rshiftWord = {
    byteValue = 33,
    numOperands = 1,
    verifyEach = function(operand)
        assert(
            operand.definition == ccasm.operandTypes.dataRegister or
            operand.definition == ccasm.operandTypes.addressRegister,
            "rshiftWord: Operand must be data or address register."
        );
    end,
    execute = function(operand)
        ccasm.operandUtils.long(operand).set(
            ccasm.integer.rightShiftBytes(ccasm.operandUtils.long(operand).get(), 2)
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
                operand.definition == ccasm.operandTypes.dataRegister or
                operand.definition == ccasm.operandTypes.immediateData,
                name .. ": Operand must be data register or immediate data."
            );
        end,
        verifyAll = function(source, destination)
            assert(destination.definition == ccasm.operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(source, destination)
            ccasm.operandUtils[sizeDescriptor](destination).set(
                ccasm.integer.orBytes(
                    ccasm.operandUtils[sizeDescriptor](source).get(),
                    ccasm.operandUtils[sizeDescriptor](destination).get()
                )
            );
        end,
    };
end
_or(34, "orByte", "byte", 1);
_or(35, "orWord", "word", 2);
_or(36, "orLong", "long", 4);
--AND------------------------------------------------------
-- _and, since 'and' is a keyword.
local function _and(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, string.format("%s: Operand must be at most %d byte(s).", name, sizeInBytes));
            assert(
                operand.definition == ccasm.operandTypes.dataRegister or
                operand.definition == ccasm.operandTypes.immediateData,
                name .. ": Operand must be data register or immediate data."
            );
        end,
        verifyAll = function(source, destination)
            assert(destination.definition == ccasm.operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(source, destination)
            ccasm.operandUtils[sizeDescriptor](destination).set(
                ccasm.integer.andBytes(
                    ccasm.operandUtils[sizeDescriptor](source).get(),
                    ccasm.operandUtils[sizeDescriptor](destination).get()
                )
            );
        end,
    };
end
_and(37, "andByte", "byte", 1);
_and(38, "andWord", "word", 2);
_and(39, "andLong", "long", 4);
--XOR------------------------------------------------------
local function xor(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 2,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= sizeInBytes, name .. ": Operand must be at most " .. sizeInBytes .. " byte(s).");
            assert(
                operand.definition == ccasm.operandTypes.immediateData or
                operand.definition == ccasm.operandTypes.dataRegister,
                name .. ": Operand must be immediate data or data register."
            );
        end,
        verifyAll = function(source, destination)
            assert(destination.definition == ccasm.operandTypes.dataRegister, name .. ": Destination must be data register.");
        end,
        execute = function(source, destination)
            ccasm.operandUtils[sizeDescriptor](destination).set(
                ccasm.integer.xorBytes(
                    ccasm.operandUtils[sizeDescriptor](source).get(),
                    ccasm.operandUtils[sizeDescriptor](destination).get()
                )
            );
        end,
    };
end
xor(40, "xorByte", "byte", 1);
xor(41, "xorWord", "word", 2);
xor(42, "xorLong", "long", 4);
--NOT------------------------------------------------------
-- _not, since 'not' is a keyword.
local function _not(byteValue, name, sizeDescriptor, sizeInBytes)
    apiEnv[name] = {
        byteValue = byteValue,
        numOperands = 1,
        verifyEach = function(operand)
            assert(operand.sizeInBytes <= 1, name .. ": Operand must be at most " .. sizeInBytes .. " byte(s).");
            assert(operand.definition == ccasm.operandTypes.dataRegister, name .. ": Operand must be data register.");
        end,
        execute = function(operand)
            ccasm.operandUtils[sizeDescriptor](operand).set(
                ccasm.integer.notBytes(
                    ccasm.operandUtils[sizeDescriptor](operand).get()
                )
            );
        end,
    };
end
_not(43, "notByte", "byte", 1);
_not(44, "notWord", "word", 2);
_not(45, "notLong", "long", 4);
--TRAP-----------------------------------------------------
local function readStringFromMemory(absoluteAddress)
    local str = "";
    local offset = 0;
    local limit = 1024;
    while offset <= limit do
        local byte = (ccasm.memory.readBytes(absoluteAddress + offset, 1))[1];
        offset = offset + 1;
        if byte == 0 then
            break;
        else
            str = str .. string.char(byte);
        end
    end
    if offset >= limit then
        error("readStringFromMemory: Read " .. limit .. " bytes before stopping string read.");
    end
    return str;
end

apiEnv.trap = {
    byteValue = 46,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.immediateData, "trap: Operand must be immediate data.");
        assert(operand.sizeInBytes == 1, "trap: Operand must be at most 1 byte.");
    end,
    execute = function(operand)
        local byte = (ccasm.operandUtils.byte(operand).get())[1];
        -- getTerminalDimensions
        if byte == 0 then
            local width, height = term.getSize();
            ccasm.registers.dataRegisters[6].setLong(
                ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(width), 4)
            );
            ccasm.registers.dataRegisters[7].setLong(
                ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(height), 4)
            );
        -- getCursorPosition
        elseif byte == 1 then
            local cursorX, cursorY = term.getCursorPos();
            ccasm.registers.dataRegisters[6].setLong(
                ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(cursorX), 4)
            );
            ccasm.registers.dataRegisters[7].setLong(
                ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(cursorY), 4)
            );
        -- setCursorPosition
        elseif byte == 2 then
            term.setCursorPos(
                ccasm.integer.getSignedIntegerFromBytes(
                    ccasm.registers.dataRegisters[0].getLong()
                ),
                ccasm.integer.getSignedIntegerFromBytes(
                    ccasm.registers.dataRegisters[1].getLong()
                )
            );
        -- clearScreen
        elseif byte == 3 then
            term.clear();
        -- clearLine
        elseif byte == 4 then
            term.clearLine();
        -- writeString
        elseif byte == 5 then
            local absoluteAddress = ccasm.integer.getIntegerFromBytes(ccasm.registers.addressRegisters[0].getWord());
            local str = readStringFromMemory(absoluteAddress);
            term.write(str);
        -- readString
        elseif byte == 6 then
            local str = read();
            local strBytes = {};
            for char in str:gmatch(".") do
                table.insert(strBytes, string.byte(char));
            end
            table.insert(strBytes, 0); -- Append null-terminator.
            ccasm.memory.writeBytes(
                ccasm.integer.getIntegerFromBytes(ccasm.registers.addressRegisters[0].getWord()),
                strBytes
            );
        -- getStringLength not including null terminator
        elseif byte == 7 then
            local absoluteAddress = ccasm.integer.getIntegerFromBytes(ccasm.registers.addressRegisters[0].getWord());
            local str = readStringFromMemory(absoluteAddress);
            ccasm.registers.dataRegisters[0].setLong(ccasm.integer.getBytesForInteger(4, str:len()));
        elseif byte == 8 then
            os.shutdown();
        elseif byte == 9 then
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