local function main(testsDirectoryPath)
    if isDirectoryPathValid(testsDirectoryPath) then
        local tests = loadTestsFromDirectory(testsDirectoryPath);
        runTests(tests);
    else
        printUsage();
    end
end

local function isDirectoryPathValid(directoryPath)
    local absolutePath = resolveLocalPathToAbsolutePath(directoryPath);
    local isValidPath = fs.exists(absolutePath) and fs.isDir(absolutePath);

    return isValidPath;
end

local function loadTestsFromDirectory(absoluteDirectoryPath)
    return {};
end

local function runTests(test)
end

local function printUsage()
    print("test_runner <directory-path>");
    print("Examples:");
    print("test_runner .");
    print("test_runner ./my_tests");
end

local commandLineArgs = { ... };
local testsDirectoryPath = commandLineArgs[1];
main(testsDirectoryPath);
