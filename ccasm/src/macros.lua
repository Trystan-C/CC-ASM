assert(os.loadAPI("//ccasm/src/operandTypes.lua"));

declareByte = {
    numOperands = 1;
    operandVerifiers = {
        acceptsOnlyImmediateData = function(definition, valueBytes, sizeInBytes)
            local condition = definition == operandTypes.immediateData;
            local errorMessage = "declareByte: Operand must be immediate data.";
            assert(condition, errorMessage);
        end,

        sizeShouldBeOneByte = function(definition, valueBytes, sizeInBytes)
            local condition = sizeInBytes == 1;
            local errorMessage = "declareByte: Operand size should be 1 byte, was: " .. tostring(sizeInBytes);
            assert(condition, errorMessage);
        end
    };
};