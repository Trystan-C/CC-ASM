assert(os.loadAPI("/ccasm/src/operandTypes.lua"));

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
};

