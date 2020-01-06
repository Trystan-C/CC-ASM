assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/assembler.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

local args = { ... };
if #args < 1 then
    print("assemble <file1.ccasm> <file2.ccasm> ... <fileN.ccasm>");
    return;
end

for _, filePath in ipairs(args) do
    local filePath = shell.resolve(filePath);
    if filePath:match("%.ccasm$") and fs.exists(filePath) then
        print("Assembling " .. filePath .. "...");
        local result, errorMessage = pcall(function()
            local inFile = fs.open(filePath, "r");
            local code = inFile.readAll();
            inFile.close();

            local objectCode = assembler.assemble(code);
            local objectFilePath = filePath:match("^(.+)%.ccasm$") .. ".cco";
            print("Writing object file " .. objectFilePath .. "...");
            local outFile = fs.open(objectFilePath, "wb");
            -- Write origin as first word.
            local originBytes = tableUtils.fitToSize(integer.getBytesForInteger(objectCode.origin), 2);
            outFile.write(originBytes[1]);
            outFile.write(originBytes[2]);
            -- Write binary output as remaining code.
            for _, byte in ipairs(objectCode.binaryOutput) do
                outFile.write(byte);
            end
            outFile.close();
        end);
        if not result then
            print("ERROR: " .. errorMessage);
        end
    else
        print("Skipping " .. filePath .. ": No .ccasm extension or file does not exist.");
    end
end