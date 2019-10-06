assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");

origin = {
    numOperands = 1;
    individualOperandVerifiers = {
        acceptsOnlyImmediateData = function(operand)
            local condition = operand.definition == operandTypes.immediateData;
            local errorMessage = "origin: Operand must be immediate data.";
            assert(condition, errorMessage);
        end,

        sizeShouldBeAtMostTwoBytes = function(operand)
            local condition = operand.sizeInBytes >= 1 and operand.sizeInBytes <= 2;
            local errorMessage = "origin: Operand size should be at most 2 bytes, was: " .. tostring(operand.sizeInBytes);
            assert(condition, errorMessage);
        end,
    };
    assemble = function(objectCode, operands)
        objectCode.origin = integer.getIntegerFromBytes(operands[1].valueBytes);
        return {};
    end
};

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
    assemble = function(objectCode, operands)
        return operands[1].valueBytes;
    end
};