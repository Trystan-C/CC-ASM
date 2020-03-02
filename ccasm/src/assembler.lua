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
    local tokens = {};

    for line in code:gmatch("[^\n]+") do
        local curToken = '';
        local isBuildingString = false;

        local function append(char)
            curToken = curToken .. char;
        end
        local function isNextToken()
            return curToken == '';
        end
        local function nextToken()
            if not isNextToken() then
                table.insert(tokens, curToken);
            end
            curToken = '';
        end

        for char in line:gmatch('.') do
            if char == ';' and not isBuildingString then
                break;
            elseif char == '"' then
                if not isBuildingString and not isNextToken() then
                    error('Unexpected character: "');
                end
                isBuildingString = not isBuildingString;
                append(char);
                if not isBuildingString then
                    nextToken();
                end
            elseif (char:match("[%s,]") and isBuildingString) or not char:match("[%s\r\n\t,]") then
                append(char);
            else
                nextToken();
            end
        end
        nextToken();
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

local function throwUnexpectedTokenError(token)
    local message = "Unexpected token: " .. token;
    error(message);
end

local function throwSymbolRedefinitionError(symbol)
    local message = "Symbol cannot be defined more than once: " .. tostring(symbol) .. ".";
    error(message);
end

local function isNextTokenAnInstruction()
    return ccasm.instructions[peekNextToken()] ~= nil;
end

local function isNextTokenAnOperand()
    return ccasm.operandTypes.getType(peekNextToken()) ~= ccasm.operandTypes.invalidType;
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
    local definition = ccasm.operandTypes[ccasm.operandTypes.getType(token)]

    if definition == ccasm.operandTypes.symbolicAddress or definition == ccasm.operandTypes.absoluteSymbolicAddress then
        markSymbolicAddressFillIndex(definition.match(token));
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
    local definition = ccasm.instructions[dequeueNextToken()];
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
    local definition = ccasm.macros[dequeueNextToken()];
    local operands = {};

    for _ = 1, definition.numOperands do
        table.insert(operands, parseOperandFromNextToken(definition.verifyEach));
    end

    local bytes = definition.assemble(objectCode, operands);
    appendBytesToBinaryOutput(unpack(bytes));
end

local function isNextTokenMacro()
    return ccasm.macros[peekNextToken()] ~= nil;
end

local function fillReferencesForSymbol(definition)
    local indexInBinaryOutput = definition.indexInBinaryOutput;

    for _, fillIndex in ipairs(definition.fillIndices) do
        local offset = indexInBinaryOutput - fillIndex;
        local offsetBytes = ccasm.integer.getBytesForInteger(ccasm.operandTypes.symbolicAddress.sizeInBytes, offset);
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
    local symbol = ccasm.operandTypes.symbolicAddress.match(dequeueNextToken());

    if symbolIsDeclared(symbol) then
        throwSymbolRedefinitionError(symbol);
    end

    addSymbolicAddress(symbol);
end

local function isNextTokenSymbol()
    local token = peekNextToken();
    return ccasm.operandTypes.getType(token) == "symbolicAddress";
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

    return ccasm.tableUtils.deepCopy(objectCode);
end

function assembleFile(filePath)
    if filePath:match("%.ccasm$") and fs.exists(filePath) then
        local inFile = fs.open(filePath, "r");
        local code = inFile.readAll();
        inFile.close();

        local objectCode = ccasm.assembler.assemble(code);
        local objectFilePath = filePath:match("^(.+)%.ccasm$") .. ".cco";
        local outFile = fs.open(objectFilePath, "wb");
        -- Write origin as first word.
        local originBytes = ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(objectCode.origin), 2);
        outFile.write(originBytes[1]);
        outFile.write(originBytes[2]);
        -- Write binary output as remaining code.
        for _, byte in ipairs(objectCode.binaryOutput) do
            outFile.write(byte);
        end
        outFile.close();
    else
        error("assembleFile(" .. filePath .. "): No .ccasm extension or file does not exist.");
    end
end