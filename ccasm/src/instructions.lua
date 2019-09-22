assert(os.loadAPI("/ccasm/src/operandTypes.lua"));
assert(os.loadAPI("/ccasm/src/registers.lua"));

moveByte = {
    byteValue = 0;
    numOperands = 2;
    individualOperandVerifiers = {
        sizeShouldBeOneByte = function(operand)
            if operand.definition ~= operandTypes.symbolicAddress then
                local condition = operand.sizeInBytes == 1;
                local errorMessage = "moveByte: Operand size " .. operand.sizeInBytes .. " ~= 1.";
                assert(condition, errorMessage);
            end
        end
    };
    groupOperandVerifiers = {
        cannotMoveBetweenAddresses = function(operand1, operand2)
            local condition = not (operand1.definition == operandTypes.symbolicAddress and
                              operand2.definition == operandTypes.symbolicAddress);
            local errorMessage = "moveByte: Cannot move directly between direct or indirect addresses addresses.";
            assert(condition, errorMessage);
        end
    };
    execute = function(operands)
        registers.dataRegisters[0].value = 5;
    end
};

moveWord = {
    byteValue = 1;
    numOperands = 2;
    individualOperandVerifiers = {
        sizeShouldBeTwoBytes = function(operand)
            if operand.definition ~= operandTypes.symbolicAddress then
                local condition = operand.sizeInBytes <= 2;
                local errorMessage = "moveWord: Operand size " .. operand.sizeInBytes .. " >= 2.";
                assert(condition, errorMessage);
            end
        end
    };
    groupOperandVerifiers = {
      cannotMoveBetweenAddresses = function(operand1, operand2)
            local condition = not (operand1.definition == operandTypes.symbolicAddress and
                              operand2.definition == operandTypes.symbolicAddress);
            local errorMessage = "moveWord: Cannot move directly between direct or indirect addresses addresses.";
            assert(condition, errorMessage);
        end
    };
    execute = function(operands)
        print("TODO: execute--moveWord");
    end
};

local function isInstructionDefinition(definition)
    return type(definition) == "table" and
            definition.byteValue ~= nil and
            definition.numOperands ~= nil;
end

byteToDefinitionMap = {};
for name, definition in pairs(getfenv()) do
    if isInstructionDefinition(definition) then
        byteToDefinitionMap[definition.byteValue] = definition;
    end
end