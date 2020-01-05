assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/instructions.lua");
apiLoader.loadIfNotPresent("/ccasm/src/macros.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");

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

local function throwUnexpectedTokenError(token)
    local message = "Unexpected token: " .. token;
    error(message);
end

local function throwSymbolRedefinitionError(symbol)
    local message = "Symbol cannot be defined more than once: " .. tostring(symbol) .. ".";
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

local function parseOperandFromNextToken(verify)
    if not isNextTokenAnOperand() then
        throwUnexpectedTokenError(token);
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
    verify(operand);

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

local function appendInstructionAsBinary(instructionByte)
    appendBytesToBinaryOutput(instructionByte);
end

local function assembleNextTokenAsInstruction()
    local definition = instructions[dequeueNextToken()];
    local numOperands = definition.numOperands;
    local operands = {};

    appendInstructionAsBinary(definition.byteValue);

    for _ = 1, numOperands do
        local verifiers = definition.verifyEach;
        local operand = assembleNextTokenAsInstructionOperand(verifiers);
        table.insert(operands, operand);
    end

    if definition.verifyAll then
        definition.verifyAll(unpack(operands));
    end
end

local function assembleNextTokenAsMacro()
    local definition = macros[dequeueNextToken()];
    local operands = {};

    for _ = 1, definition.numOperands do
        table.insert(operands, parseOperandFromNextToken(definition.verifyEach));
    end

    local bytes = definition.assemble(objectCode, operands);
    appendBytesToBinaryOutput(unpack(bytes));
end

local function isNextTokenMacro()
    return macros[peekNextToken()] ~= nil;
end

local function fillReferencesForSymbol(definition)
    local indexInBinaryOutput = definition.indexInBinaryOutput;

    for _, fillIndex in ipairs(definition.fillIndices) do
        local offset = indexInBinaryOutput - fillIndex;
        local offsetBytes = integer.getBytesForInteger(operandTypes.symbolicAddress.sizeInBytes, offset);
        insertBytesIntoBinaryOutputAt(fillIndex, unpack(offsetBytes));
    end
end

local function fillSymbolAddressReferences()
    for symbol, definition in pairs(objectCode.symbols) do
        if not symbolIsDeclared(symbol) then
            error("Symbol is used but never declared: " .. tostring(symbol) .. ".");
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
    local symbol = operandTypes.symbolicAddress.match(dequeueNextToken());

    if symbolIsDeclared(symbol) then
        throwSymbolRedefinitionError(symbol);
    end

    addSymbolicAddress(symbol);
end

local function isNextTokenSymbol()
    local token = peekNextToken();
    return operandTypes.getType(token) == "symbolicAddress";
end

local function reset()
    tokenIndex = 1;

    objectCode = {
        origin = 0;
        symbols = {};
        binaryOutput = {};
    };
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
            throwUnexpectedTokenError(dequeueNextToken());
        end
    end

    fillSymbolAddressReferences();

    return tableUtils.deepCopy(objectCode);
end