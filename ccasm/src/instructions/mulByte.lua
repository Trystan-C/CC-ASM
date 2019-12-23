assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 9;
numOperands = 2;

individualOperandVerifiers = {
    operandMustBeOneByte = function(operand)
        assert(operand.sizeInBytes == 1, "mulByte: Operand must be one byte.");
    end,
};

groupOperandVerifiers = {
    sourceVerifier = function(from, to)
        assert(
            from.definition == operandTypes.dataRegister or
            from.definition == operandTypes.immediateData,
            "mulByte: Source must be data register or immediate data."
        );
    end,
    destinationVerifier = function(from, to)
        assert(to.definition == operandTypes.dataRegister, "mulByte: Destination must be data register.");
    end,
};

function execute(from, to)
    local product = integer.multiplyBytes(
        operandUtils.byte(from).get(),
        operandUtils.byte(to).get()
    );
    operandUtils.byte(to).set(tableUtils.fitToSize(product, 1));
end