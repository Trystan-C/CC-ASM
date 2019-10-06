assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");

declareByte = {
    numOperands = 1;
    individualOperandVerifiers = {
        acceptsOnlyImmediateData = function(operand)
            local condition = operand.definition == operandTypes.immediateData;
            local errorMessage = "declareByte: Operand must be immediate data.";
            assert(condition, errorMessage);
        end,

        sizeShouldBeOneByte = function(operand)
            local condition = operand.sizeInBytes == 1;
            local errorMessage = "declareByte: Operand size should be 1 byte, was: " .. tostring(operand.sizeInBytes);
            assert(condition, errorMessage);
        end
    };
};