assert(os.loadAPI("/ccasm/src/operandTypes.lua"));

moveByte = {
    byteValue = 0;
    numOperands = 2;
    operandVerifiers = {
        sizeShouldBeOneByte = function(definition, valueBytes, sizeInBytes)
            if definition ~= operandTypes.symbolicAddress then
                local condition = sizeInBytes == 1;
                local errorMessage = "moveByte: Operand size " .. sizeInBytes .. " ~= 1.";
                assert(condition, errorMessage);
            end
        end
    };
};

moveWord = {
    byteValue = 1;
    numOperands = 2;
    operandVerifiers = {
        sizeShouldBeTwoBytes = function(definition, valueBytes, sizeInBytes)
            if definition ~= operandTypes.symbolicAddress then
                local condition = sizeInBytes <= 2;
                local errorMessage = "moveWord: Operand size " .. sizeInBytes .. " >= 2.";
                assert(condition, errorMessage);
            end
        end
    };
};

