assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 8;
numOperands = 2;

groupOperandVerifiers = {
    sourceCannotBeSymbolicAddress = function(from, to)
        assert(from.definition ~= operandTypes.symbolicAddress, "subLong: Source cannot be symbolic address.");
    end,

    destinationMustBeDataRegister = function(from, to)
        assert(to.definition == operandTypes.dataRegister, "subLong: Destination must be data register.");
    end,
};

function execute(from, to)
    local fromLong = operandUtils.long(from).get();
    local toLong = operandUtils.long(to).get();
    local difference = integer.subtractBytes(toLong, fromLong);
    operandUtils.long(to).set(tableUtils.fitToSize(difference, 4));
end