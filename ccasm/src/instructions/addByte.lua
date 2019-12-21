assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");

byteValue = 3;
numOperands = 2;

individualOperandVerifiers = {
    sizeShouldBeOneByte = function(operand)
        if operand.definition ~= operand.symbolicAddress then
            assert(
                operand.sizeInBytes == 1,
                "addByte: operand must be 1 byte"
            );
        end
    end
};

groupOperandVerifiers = {
    fromMustBeImmediateDataOrDataRegister = function(from, to)
        assert(
            from.definition == operandTypes.dataRegister or
            from.definition == operandTypes.immediateData,
            "addByte: source must be data register."
        );
    end,
    
    destinationMustBeDataRegister = function(from, to)
        assert(
            to.definition == operandTypes.dataRegister,
            "addByte: destination must be a data register."
        );
    end,
};

function execute(from, to)
    local fromData = operandUtils.byte(from).get();
    local toData = operandUtils.byte(to).get();
    local sum = tableUtils.fitToSize(integer.addBytes(fromData, toData), 1);
    operandUtils.byte(to).set(sum);
end
