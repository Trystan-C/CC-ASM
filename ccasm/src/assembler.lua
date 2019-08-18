assert(os.loadAPI("/ccasm/src/instructions.lua"));
assert(os.loadAPI("/ccasm/src/operandTypes.lua"));
assert(os.loadAPI("/ccasm/src/cpu.lua"));

local objectCode = {};
local tokens = nil;
local tokenIndex = 1;
local numTokens = 0;

local function assertIsByte(byte)
    assert(type(byte) == "number");
    assert(math.floor(byte) == byte);
    assert(byte >= 0 and byte <= 255);
end

local function appendBytesToBinaryOutput(...)
    local bytes = { ... };

    for _, byte in ipairs(bytes) do
        assertIsByte(byte);
        table.insert(objectCode.binaryOutput, byte);
    end
end

local function parseTokensFromCode(code)
    local tokens = {};

    for token in code:gmatch("[^%s\r\n\t,]+") do
        table.insert(tokens, token);
    end

    return tokens;
end

local function peekNextToken()
    return tokens[tokenIndex];
end

local function throwNotEnoughSymbolsError()
    local message = "Expected another symbol but none were available.";
    error(message);
end

local function dequeueNextToken()
    if tokenIndex > numTokens then
        throwNotEnoughSymbolsError();
    end

    local token = peekNextToken();
    tokenIndex = tokenIndex + 1

    return token;
end

local function throwUnexpectedSymbolError(token)
    local message = "Unexpected symbol: " .. token;
    error(message);
end

local function throwUnrecognizedOperandTypeError(token)
    local message = "Unrecognized operand type for token: " .. tostring(token);
    error(message);
end

local function isNextTokenAnInstruction()
    return instructions[peekNextToken()] ~= nil;
end

local function isNextTokenAnOperand()
    return operandTypes.getType(peekNextToken()) ~= operandTypes.invalidType;
end

local function appendOperandAsBinary(typeByte, sizeByte, valueBytes)
    appendBytesToBinaryOutput(typeByte, sizeByte, unpack(valueBytes));
end

local function assembleNextTokenAsOperand()
    if not isNextTokenAnOperand() then
        throwUnexpectedSymbolError(token);
    end

    local token = dequeueNextToken();
    local definition = operandTypes[operandTypes.getType(token)]

    if definition == nil then
        throwUnrecognizedOperandTypeError(token);
    end

    local typeByte = definition.typeByte;
    local value = definition.parseValueAsBytes(token);
    local size = #value

    appendOperandAsBinary(typeByte, size, value);
end

local function appendInstructionAsBinary(instructionByte)
    appendBytesToBinaryOutput(instructionByte);
end

local function assembleNextTokenAsInstruction()
    local definition = instructions[dequeueNextToken()];
    local numOperands = definition.numOperands;

    appendInstructionAsBinary(definition.byteValue);

    for _ = 1, numOperands do
        assembleNextTokenAsOperand();
    end
end

local function assembleSymbol()
end

local function isNextTokenAnUnusedSymbol()
    return false;
end

local function reset()
    tokenIndex = 1;

    objectCode = {
        origin = nil,
        symbols = {},
        binaryOutput = {}
    };
end

-- NOTE: Does not support table keys or metatables.
local function deepCopy(tbl)
    local copy = {};

    for key, value in pairs(tbl) do
        if type(value) == "table" then
            copy[key] = deepCopy(value);
        else
            copy[key] = value;
        end
    end

    return copy;
end

function assemble(code)
    reset();

    tokens = parseTokensFromCode(code);
    numTokens = #tokens;

    while tokenIndex <= numTokens do
        if isNextTokenAnInstruction() then
            assembleNextTokenAsInstruction();
        elseif not isNextTokenAnUnusedSymbol() then
            assembleSymbol();
        else
            local token = dequeueNextToken();
            throwUnexpectedSymbolError(token);
        end
    end

    -- TODO: Create a deep copy of the object code table.
    return deepCopy(objectCode);
end