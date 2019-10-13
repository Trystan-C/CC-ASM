assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/assembler.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local apiEnv = getfenv();
local objectCode = nil;
local binaryCodePtr = nil;

local function getNextByteFromBinaryOutput()
    local nextByte = objectCode.binaryOutput[binaryCodePtr];
    binaryCodePtr = binaryCodePtr + 1;

    if nextByte == nil then
        local tooFewBytesMessage = "Ran out of bytes. Are some data not being appended?";
        error(tooFewBytesMessage);
    end

    return nextByte;
end

function nextOperandShouldBe(operand)
    local operandBytes = integer.getBytesForInteger(operand);

    for _, operandByte in ipairs(operandBytes) do
        local nextByte = getNextByteFromBinaryOutput();
        local byteMatchesOperand = nextByte == operandByte;
        assert(byteMatchesOperand, "Unexpected operand value.");
    end

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
        nextOperandTypeShouldBe = apiEnv.nextOperandTypeShouldBe;
    };
end

function nextOperandShouldBeReferenceToSymbol(sizeInBytes, symbol)
    apiEnv.symbolShouldExist(symbol);
    local startPtr = binaryCodePtr;
    local offsetBytes = {};
    for _ = 1, sizeInBytes do
        table.insert(offsetBytes, getNextByteFromBinaryOutput());
    end

    local symbolPtr = startPtr + integer.getSignedIntegerFromBytes(offsetBytes);
    local symbolRelativeAddress = objectCode.symbols[symbol].indexInBinaryOutput;
    local condition = symbolPtr == symbolRelativeAddress;
    local message = "Expected operand to reference symbol at " .. tostring(symbolRelativeAddress) .. " but pointed to " .. tostring(symbolPtr) .. ".";
    assert(condition, message);

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
        nextOperandTypeShouldBe = apiEnv.nextOperandTypeShouldBe;
    };
end

function nextOperandSizeInBytesShouldBe(sizeInBytes)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperandSize = nextByte == sizeInBytes;
    assert(byteMatchesOperandSize, "Expected operand size to be " .. tostring(sizeInBytes) .. " but was " .. tostring(nextByte) .. ".");

    return {
        nextOperandShouldBe = apiEnv.nextOperandShouldBe;
        nextOperandShouldBeReferenceToSymbol = function(symbol)
            return apiEnv.nextOperandShouldBeReferenceToSymbol(sizeInBytes, symbol);
        end
    };
end

function nextOperandTypeShouldBe(operandTypeDefinition)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperandType = nextByte == operandTypeDefinition.typeByte;
    local errorMessage = "Unexpected operand type: " .. tostring(operandType);
    assert(byteMatchesOperandType, errorMessage);

    return {
        nextOperandSizeInBytesShouldBe = apiEnv.nextOperandSizeInBytesShouldBe;
    };
end

function nextInstructionShouldBe(instructionDefinition)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesInstruction = nextByte == instructionDefinition.byteValue;
    assert(byteMatchesInstruction, "Unexpected instruction.");

    return {
        nextOperandTypeShouldBe = apiEnv.nextOperandTypeShouldBe;
    };
end

function offsetByBytes(numBytes)
    binaryCodePtr = binaryCodePtr + numBytes;

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
    };
end

function valueAtSymbolShouldBe(symbol, value)
    local sizeInBytes = integer.getSizeInBytesForInteger(value);
    local valueBytes = integer.getBytesForInteger(sizeInBytes, value);
    local relativeAddress = objectCode.symbols[symbol].indexInBinaryOutput;

    for offset, valueByte in ipairs(valueBytes) do
        local nextByte = objectCode.binaryOutput[relativeAddress + offset - 1];
        local condition = nextByte == valueByte;
        local errorMessage = "Expected byte at symbol offset " .. (offset - 1) .. " to be " .. valueByte .. ", got " .. tostring(nextByte) .. ".";
        assert(condition, errorMessage);
    end

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
        offsetByBytes = apiEnv.offsetByBytes;
    };
end

function symbolShouldExist(symbol)
    local symbolExists = objectCode.symbols[symbol] ~= nil;
    local errorMessage = "Expected symbol '" .. symbol .. "' to exist.";
    assert(symbolExists, errorMessage);

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
        valueAtSymbolShouldBe = function(value)
            return apiEnv.valueAtSymbolShouldBe(symbol, value);
        end
    };
end

local function clearAssembleOutput()
    objectCode = {};
    binaryCodePtr = 1;
end

function assemble(code)
    clearAssembleOutput();
    objectCode = assembler.assemble(code);

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
        symbolShouldExist = apiEnv.symbolShouldExist;
    };
end
