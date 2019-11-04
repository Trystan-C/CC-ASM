assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 6;
numOperands = 2;

function execute(from, to)
    local fromByte = operandUtils.byte(from).get();
    local toByte = operandUtils.byte(to).get();
    local difference = integer.subtractBytes(toByte, fromByte);
    operandUtils.byte(to).set(tableUtils.trimToSize(difference, 1));
end