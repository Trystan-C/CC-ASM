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
            local objectFilePath = ccasm.assembler.assembleFile(filePath);
            print("Wrote object file " .. objectFilePath .. ".");
        end);
        if not result then
            print("ERROR: " .. errorMessage);
        end
    else
        print("Skipping " .. filePath .. ": No .ccasm extension or file does not exist.");
    end
end