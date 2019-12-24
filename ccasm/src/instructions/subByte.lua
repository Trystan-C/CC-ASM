assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 6;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes == 1, "subByte: Operand must be 1 byte.");
    end,
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.immediateData or
            from.definition == operandTypes.dataRegister,
            "subByte: Source must be immediate data or data reigster."
        );
        assert(to.definition == operandTypes.dataRegister, "subByte: Destination must be data register.");
    end,
};

function execute(from, to)
    local fromByte = operandUtils.byte(from).get();
    local toByte = operandUtils.byte(to).get();
    local difference = integer.subtractBytes(toByte, fromByte);
    operandUtils.byte(to).set(tableUtils.fitToSize(difference, 1));
end