--[[
    This module isolates file-system calls to an owned
    set of functions, allowing dependent modules to be
    executed in a Lua environment separate from Computer Craft
    with changes localized only to this file.
--]]

function doesFileExist(absoluteFilePath)
    return fs.exists(absoluteFilePath);
end

function getAbsoluteFilePathsInDirectory(absoluteDirectoryPath)
    return fs.list(absoluteDirectoryPath);
end