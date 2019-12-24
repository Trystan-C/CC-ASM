assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 12;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes == 1, "divByte: Operand must be 1 byte.");
    end,
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.immediateData or
            from.definition == operandTypes.dataRegister,
            "divByte: Source must be immediate data or data register."
        );
        assert(to.definition == operandTypes.dataRegister, "divByte: Destination must be data register.");
    end,
};

function execute(from, to)
    local quotient = integer.divideBytes(
        operandUtils.byte(from).get(),
        operandUtils.byte(to).get()
    );
    operandUtils.byte(to).set(tableUtils.fitToSize(quotient, 1));
end