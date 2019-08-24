moveByte = {
    byteValue = 0;
    numOperands = 2;
    operandVerifiers = {
        sizeShouldBeOneByte = function(definition, valueBytes, sizeInBytes)
            local condition = sizeInBytes == 1;
            local errorMessage = "Operand size " .. sizeInBytes .. " ~= 1.";
            assert(condition, errorMessage);
        end
    };
};