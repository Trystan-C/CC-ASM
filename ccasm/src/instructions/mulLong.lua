assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 11;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes <= 4, "mulLong: Operand must be at most 4 bytes.");
    end,
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.dataRegister or
            from.definition == operandTypes.immediateData,
            "mulLong: Source must be immediate data or data register."
        );
        assert(to.definition == operandTypes.dataRegister, "mulLong: Destination must be data register.");
    end
};

function execute(from, to)
    local product = integer.multiplyBytes(
        operandUtils.long(from).get(),
        operandUtils.long(to).get()
    );
    operandUtils.long(to).set(tableUtils.fitToSize(product, 4));
end