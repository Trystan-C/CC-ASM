assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");

byteValue = 5;
numOperands = 2;

groupOperandVerifiers = {
    sourceMustBeImmediateDataOrDataRegister = function(from, to)
        assert(
            from.definition == operandTypes.dataRegister or
            from.definition == operandTypes.immediateData,
            "addLong: source must be immediate data or data register."
        );
    end,
    destinationMustBeDataRegister = function(from, to)
        assert(to.definition == operandTypes.dataRegister, "addLong: destination must be data register.");
    end,
};

function execute(from, to)
    local sum = integer.addBytes(operandUtils.long(from).get(), operandUtils.long(to).get());
    operandUtils.long(to).set(tableUtils.trimToSize(sum, 4));
end