local function printUsage()
    print("Usage: testRunner <directory-path> -r(ecurse) | <file-path>");
end

local function isFunction(value)
    return type(value) == "function";
end

local function getAndRemoveFunctionEntry(theTable, key)
    local func = function() end

    if isFunction(theTable[key]) then
        func = theTable[key];
        theTable[key] = nil;
    end

    return func;
end

local function addShellToFunctionEnvironment(func)
    local currentEnv = getfenv(func);
    currentEnv["_G"].shell = shell;
end

local function runTest(testName, testFunc)
    print("- Running test: " .. testName);
    addShellToFunctionEnvironment(testFunc);
    local success, errorMessage = pcall(testFunc);
    local testPassed = false;

    if not success then
        print("- Fail: " .. tostring(errorMessage));
    else
        testPassed = true;
    end

    return testPassed;
end

local function runTestSuite(testSuite)
    local beforeAll = getAndRemoveFunctionEntry(testSuite, "beforeAll");
    local beforeEach = getAndRemoveFunctionEntry(testSuite, "beforeEach");
    local afterEach = getAndRemoveFunctionEntry(testSuite, "afterEach");
    local afterAll = getAndRemoveFunctionEntry(testSuite, "afterAll");

    if testSuite["only"] ~= nil then
        print("->Running 'only' sub-suite<-");
        return runTestSuite(testSuite["only"]);
    end

    local passedNames = {};
    local failedNames = {};

    beforeAll();
    for testName, testFunc in pairs(testSuite) do
        beforeEach();

        local testPassed = runTest(testName, testFunc);
        if testPassed then
            table.insert(passedNames, testName);
        else
            table.insert(failedNames, testName);
        end

        afterEach();
    end
    afterAll();

    return {
        passes = passedNames,
        failures = failedNames,
    };
end

local function printTestFailures(failures)
    print("Tests failed:");
    for suiteName, testNames in pairs(failures) do
        print(suiteName .. ":");
        for _, testName in ipairs(testNames) do
            print("\t\t- " .. testName);
        end
    end
end


local function printTestReport(report)
    local totalTestsPassed = 0;
    local totalTestsFailed = 0;
    local failures = {};
    for suiteName, suiteReport in pairs(report) do
        totalTestsPassed = totalTestsPassed + #suiteReport.passes;
        totalTestsFailed = totalTestsFailed + #suiteReport.failures;
        failures[suiteName] = #suiteReport.failures > 0 and suiteReport.failures or nil;
    end
    local totalTestsRun = totalTestsPassed + totalTestsFailed;
    print(string.format("%d tests passed, %d failed of %d tests run.", totalTestsPassed, totalTestsFailed, totalTestsRun));
    if totalTestsFailed > 0 then
        print("--FAILURES--------");
        printTestFailures(failures);
    end
end

local function runTestSuites(testSuites)
    local report = {};

    for suiteName, testSuite in pairs(testSuites) do
        print("Running test suite: " .. suiteName);
        report[suiteName] = runTestSuite(testSuite);
    end

    printTestReport(report);
end

local function loadTestSuiteFromTestFile(absoluteTestFilePath)
    local testSuite = {};
    local testFileHandle = fs.open(absoluteTestFilePath, "r");
    local testFileContents = testFileHandle.readAll();
    testFileHandle.close();

    local testFileAsFunction, errorMessage = loadstring(testFileContents);

    if testFileAsFunction == nil then
        local testLoadErrorMessage = "Failed to load test suite at " ..
                                     absoluteTestFilePath .. ": " .. errorMessage;
        error(testLoadErrorMessage);
    else
        testSuite = testFileAsFunction();
    end

    return testSuite;
end

local function isTestFile(absoluteFilePath)
    local isFile = not fs.isDir(absoluteFilePath);
    local endsWithTests = absoluteFilePath:match(".-Tests%.lua") ~= nil;

    return isFile and endsWithTests;
end

local function getTestFilePathsInDirectory(absoluteDirectoryPath)
    local filesInDirectory = fs.list(absoluteDirectoryPath);
    local absoluteTestFilePaths = {};

    for _, absoluteFilePath in pairs(filesInDirectory) do
        if isTestFile(absoluteFilePath) then
            table.insert(absoluteTestFilePaths, absoluteFilePath);
        end
    end

    return absoluteTestFilePaths;
end

local function getTestSuiteNameFromAbsoluteFilePath(absoluteTestFilePath)
    return absoluteTestFilePath:match("^(.+)%.lua");
end

local function loadTestSuitesFromDirectory(absoluteDirectoryPath)
    local testSuites = {};
    local testFilesInDirectory = getTestFilePathsInDirectory(absoluteDirectoryPath);

    for _, fileName in pairs(testFilesInDirectory) do
        local absoluteTestFilePath = absoluteDirectoryPath .. '/' .. fileName;
        local testSuite = loadTestSuiteFromTestFile(absoluteTestFilePath);
        local suiteName = getTestSuiteNameFromAbsoluteFilePath(absoluteTestFilePath);
        testSuites[suiteName] = testSuite;
    end

    return testSuites;
end

local function isString(value)
    return type(value) == "string";
end

local function isDirectoryPathValid(absolutePath)
    if not isString(absolutePath) then
        return false;
    end

    return fs.exists(absolutePath) and fs.isDir(absolutePath);
end

local function isFilePathValid(absolutePath)
    if not isString(absolutePath) then
        return false;
    end

    return fs.exists(absolutePath) and not fs.isDir(absolutePath);
end

local function populateDirectoryTree(directories)
    local root = directories[#directories];
    if root == nil or not fs.isDir(root) then
        return;
    end
    for _, fileName in ipairs(fs.list(root)) do
        local path = root .. "/" .. fileName;
        if fs.isDir(path) then
            table.insert(directories, path);
            populateDirectoryTree(directories);
        end
    end
end

local function composeSuites(superSuites, subSuites)
    for suiteName, suite in pairs(subSuites) do
        if superSuites[suiteName] == nil then
            superSuites[suiteName] = suite;
        else
            error("Test suite name collision: " .. suiteName);
        end
    end
end

local function recursivelyRunTestsInDirectory(absoluteRootDirectoryPath)
    local directories = { absoluteRootDirectoryPath };
    local testSuites = {};
    populateDirectoryTree(directories);
    for _, absoluteDirectoryPath in ipairs(directories) do
        local testSuitesInDir = loadTestSuitesFromDirectory(absoluteDirectoryPath);
        composeSuites(testSuites, testSuitesInDir);
    end
    runTestSuites(testSuites);
end

local function runTestsInDirectory(absoluteDirectoryPath)
    local testSuites = loadTestSuitesFromDirectory(absoluteDirectoryPath);
    runTestSuites(testSuites);
end

local function runTestsInFile(absoluteFilePath)
    local testSuite = loadTestSuiteFromTestFile(absoluteFilePath);
    local suiteName = getTestSuiteNameFromAbsoluteFilePath(absoluteFilePath);
    local report = { [suiteName] = runTestSuite(testSuite) };
    printTestReport(report);
end

local function loadNewCCASMInstance()
    shell.run("/ccasm/ccasm.lua");
end

local function main(testsDirectoryPath, recurse)
    if testsDirectoryPath ~= nil then
        local absoluteTestPath = shell.resolve(testsDirectoryPath);
        local runnerFunction = nil;

        if isDirectoryPathValid(absoluteTestPath) then
            if recurse then
                runnerFunction = recursivelyRunTestsInDirectory;
            else
                runnerFunction = runTestsInDirectory;
            end
        elseif isFilePathValid(absoluteTestPath) then
            runnerFunction = runTestsInFile;
        end

        if runnerFunction ~= nil then
            loadNewCCASMInstance();
            return runnerFunction(absoluteTestPath);
        end
    end
    printUsage();
end

local commandLineArgs = { ... };
local testsDirectoryPath = commandLineArgs[1];
local recurse = commandLineArgs[2] == "-r";
main(testsDirectoryPath, recurse);