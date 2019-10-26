assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");

byteValue = 5;
numOperands = 2;

groupOperandVerifiers = {
    destinationCannotBeSymbolicAddress = function(from, to)
        assert(to.definition ~= operandTypes.symbolicAddress, "addLong: Destination cannot be symbolic address.");
    end
};

function execute(from, to)
    local sum = integer.addBytes(operandUtils.long(from).get(), operandUtils.long(to).get());
    operandUtils.long(to).set(tableUtils.trimToSize(sum, 4));
end