assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 8;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes <= 4, "subLong: Operand must be at most 4 bytes.");
    end
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.immediateData or
            from.definition == operandTypes.dataRegister,
            "subLong: Source must be immediate data or data register."
        );
        assert(to.definition == operandTypes.dataRegister, "subLong: Destination must be data register.");
    end,
};

function execute(from, to)
    local fromLong = operandUtils.long(from).get();
    local toLong = operandUtils.long(to).get();
    local difference = integer.subtractBytes(toLong, fromLong);
    operandUtils.long(to).set(tableUtils.fitToSize(difference, 4));
end