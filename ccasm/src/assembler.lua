os.loadAPI("/ccasm/src/instructions.lua");
os.loadAPI("/ccasm/src/operandTypes.lua");
os.loadAPI("/ccasm/src/cpu.lua");

local tokens = nil;
local tokenIndex = 0;
local numTokens = 0;

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

local function isNextTokenAnInstruction()
    return instructions[peekNextToken()] ~= nil;
end

local function isNextTokenAnOperand()
    local nextToken = peekNextToken();
    local operandType = operandTypes.getTypeFromToken(nextToken);

    return operandType ~= operandTypes.invalidType;
end

local function assembleNextTokenAsOperand(objectCode)
    if not isNextTokenAnOperand() then
        throwUnexpectedSymbolError(token);
    end
end

local function assembleNextTokenAsInstruction(objectCode)
    local definition = instructions[dequeueNextToken()];
    local numOperands = definition.numOperands;

    for i = 1, numOperands do
        assembleNextTokenAsOperand(objectCode);
    end
end

local function assembleSymbol(objectCode)
end

local function isNextTokenAnUnusedSymbol()
    return false;
end

function assemble(code)
    local objectCode = {
        origin = nil,
        symbols = {},
        binaryOutput = {}
    };

    tokens = parseTokensFromCode(code);
    numTokens = #tokens;

    for i = 1, numTokens do
        if isNextTokenAnInstruction() then
            assembleNextTokenAsInstruction(objectCode);
        elseif not isNextTokenAnUnusedSymbol() then
            assembleSymbol(objectCode);
        else
            throwUnexpectedSymbolError(token);
        end
    end

    return objectCode;
end