local function printUsage()
    print("Usage: testRunner <directory-path> | <file-path>");
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

    local passCount = 0;
    local failCount = 0;

    beforeAll();
    for testName, testFunc in pairs(testSuite) do
        beforeEach();

        local testPassed = runTest(testName, testFunc);
        if testPassed then
            passCount = passCount + 1;
        else
            failCount = failCount + 1;
        end

        afterEach();
    end
    afterAll();

    return passCount, failCount;
end

local function printTestReport(totalTestsRun, totalTestsPassed, totalTestsFailed)
    local testReportMessage = totalTestsPassed .. " passed, " .. totalTestsFailed ..
                              " failed of " .. totalTestsRun .. " tests run.";
    print(testReportMessage);
end

local function runTestSuites(testSuites)
    local totalTestsPassed = 0;
    local totalTestsFailed = 0;

    for suiteName, testSuite in pairs(testSuites) do
        print("Running test suite: " .. suiteName);
        local suitePassCount, suiteFailCount = runTestSuite(testSuite);
        totalTestsPassed = totalTestsPassed + suitePassCount;
        totalTestsFailed = totalTestsFailed + suiteFailCount;
    end

    local totalTestsRun = totalTestsPassed + totalTestsFailed;
    printTestReport(totalTestsRun, totalTestsPassed, totalTestsFailed);
end

local function getFileNameFromAbsolutePath(absoluteFilePath)
    return absoluteFilePath:match(".-/(.+)%.lua");
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

local function loadTestSuitesFromDirectory(absoluteDirectoryPath, useLongSuiteNames)
    local testSuites = {};
    local testFilesInDirectory = getTestFilePathsInDirectory(absoluteDirectoryPath);

    for _, fileName in pairs(testFilesInDirectory) do
        local absoluteTestFilePath = absoluteDirectoryPath .. '/' .. fileName;
        local testSuite = loadTestSuiteFromTestFile(absoluteTestFilePath);
        local suiteName = useLongSuiteNames and absoluteTestFilePath or getFileNameFromAbsolutePath(absoluteTestFilePath);
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
        local useLongSuiteNames = true;
        local testSuitesInDir = loadTestSuitesFromDirectory(absoluteDirectoryPath, useLongSuiteNames);
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
    local testsPassed, testsFailed = runTestSuite(testSuite);
    local totalTests = testsPassed + testsFailed;
    printTestReport(totalTests, testsPassed, testsFailed);
end

local function main(testsDirectoryPath, recurse)
    if testsDirectoryPath ~= nil then
        local absoluteTestPath = shell.resolve(testsDirectoryPath);

        if isDirectoryPathValid(absoluteTestPath) then
            if recurse then
                return recursivelyRunTestsInDirectory(absoluteTestPath)
            else
                return runTestsInDirectory(absoluteTestPath);
            end
        elseif isFilePathValid(absoluteTestPath) then
            return runTestsInFile(absoluteTestPath);
        end
    end
    printUsage();
end

local commandLineArgs = { ... };
local testsDirectoryPath = commandLineArgs[1];
local recurse = commandLineArgs[2] == "-r";
main(testsDirectoryPath, recurse);