assert(os.loadAPI("/ccasm/src/instructions.lua"));
assert(os.loadAPI("/ccasm/src/macros.lua"));
assert(os.loadAPI("/ccasm/src/operandTypes.lua"));
assert(os.loadAPI("/ccasm/src/cpu.lua"));

local objectCode = {};
local tokens;
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

local function insertBytesIntoBinaryOutputAt(index, ...)
    local bytes = { ... };

    for offset, byte in ipairs(bytes) do
        assertIsByte(byte);
        objectCode.binaryOutput[index + offset - 1] = byte;
    end
end

local function parseTokensFromCode(code)
    local parsedTokens = {};

    for token in code:gmatch("[^%s\r\n\t,]+") do
        table.insert(parsedTokens, token);
    end

    return parsedTokens;
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

local function throwSymbolRedefinitionError(symbol)
    local message = "Symbol cannot be defined more than once: " .. tostring(symbol) .. ".";
    error(message);
end

local function throwSymbolUndeclaredError(symbol)
    local message = "Symbol is used but never declared: " .. tostring(symbol) .. ".";
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

local function defineSymbol(symbol)
    objectCode.symbols[symbol] = {
        indexInBinaryOutput = nil;
        fillIndices = {};
    };
end

local function symbolExists(symbol)
    return objectCode.symbols[symbol] ~= nil;
end

local function symbolIsDeclared(symbol)
    return symbolExists(symbol) and objectCode.symbols[symbol].indexInBinaryOutput ~= nil;
end

local function markSymbolicAddressFillIndex(symbol)
    if not symbolExists(symbol) then
        defineSymbol(symbol)
    end

    -- Operand offset:
    -- 1 (next entry) + 1 (type byte) + 1 (size byte)
    local fillIndex = #objectCode.binaryOutput + 3;
    table.insert(objectCode.symbols[symbol].fillIndices, fillIndex);
end

local function parseOperandFromNextToken(verifiers)
    if not isNextTokenAnOperand() then
        throwUnexpectedSymbolError(token);
    end

    local token = dequeueNextToken();
    local definition = operandTypes[operandTypes.getType(token)]

    if definition == operandTypes.symbolicAddress then
        markSymbolicAddressFillIndex(token);
    end

    local operand = {
        definition = definition;
        valueBytes = definition.parseValueAsBytes(token);
    };
    operand.sizeInBytes = #operand.valueBytes;

    for _, verifier in pairs(verifiers) do
        verifier(operand);
    end

    return operand;
end

local function assembleNextTokenAsInstructionOperand(verifiers)
    local operand = parseOperandFromNextToken(verifiers);
    appendOperandAsBinary(
            operand.definition.typeByte,
            operand.sizeInBytes,
            operand.valueBytes
    );

    return operand;
end

local function assembleNextTokenAsMacroOperand(verifiers)
    local operand = parseOperandFromNextToken(verifiers);
    appendBytesToBinaryOutput(unpack(operand.valueBytes));
end

local function appendInstructionAsBinary(instructionByte)
    appendBytesToBinaryOutput(instructionByte);
end

local function assembleNextTokenAsInstruction()
    local definition = instructions[dequeueNextToken()];
    local numOperands = definition.numOperands;
    local operands = {};

    appendInstructionAsBinary(definition.byteValue);

    for _ = 1, numOperands do
        local verifiers = definition.individualOperandVerifiers or {};
        local operand = assembleNextTokenAsInstructionOperand(verifiers);
        table.insert(operands, operand);
    end

    for _, groupVerifier in pairs((definition.groupOperandVerifiers or {})) do
        groupVerifier(unpack(operands));
    end
end

local function assembleNextTokenAsMacro()
    local definition = macros[dequeueNextToken()];

    for _ = 1, definition.numOperands do
        assembleNextTokenAsMacroOperand(definition.individualOperandVerifiers);
    end
end

local function isNextTokenMacro()
    return macros[peekNextToken()] ~= nil;
end

local function fillReferencesForSymbol(definition)
    local indexInBinaryOutput = definition.indexInBinaryOutput;
    local addressBytes = integer.getBytesForInteger(operandTypes.symbolicAddress.sizeInBytes, indexInBinaryOutput);

    for _, fillIndex in ipairs(definition.fillIndices) do
        insertBytesIntoBinaryOutputAt(fillIndex, unpack(addressBytes));
    end
end

local function fillSymbolAddressReferences()
    for symbol, definition in pairs(objectCode.symbols) do
        if not symbolIsDeclared(symbol) then
            throwSymbolUndeclaredError(symbol)
        else
            fillReferencesForSymbol(definition)
        end
    end
end

local function addSymbolicAddress(symbol)
    if not symbolExists(symbol) then
        defineSymbol(symbol);
    end

    objectCode.symbols[symbol].indexInBinaryOutput = #objectCode.binaryOutput + 1;
end

local function assembleNextTokenAsSymbol()
    local symbol = dequeueNextToken();

    if symbolIsDeclared(symbol) then
        throwSymbolRedefinitionError(symbol);
    end

    addSymbolicAddress(symbol);
end

local function isNextTokenSymbol()
    local token = peekNextToken();
    return token:match("(%a[%w_]+)") == token;
end

local function reset()
    tokenIndex = 1;

    objectCode = {
        origin = 0;
        symbols = {};
        binaryOutput = {};
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
        elseif isNextTokenMacro() then
            assembleNextTokenAsMacro();
        elseif isNextTokenSymbol() then
            assembleNextTokenAsSymbol();
        else
            throwUnexpectedSymbolError(dequeueNextToken());
        end
    end

    fillSymbolAddressReferences();

    return deepCopy(objectCode);
end