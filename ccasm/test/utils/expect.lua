function errorToBeThrown(func)
    local success = pcall(func);
    local expectationIsMet = not success;
    local errorMessage = "Expected error to be thrown.";
    assert(expectationIsMet, errorMessage);
end