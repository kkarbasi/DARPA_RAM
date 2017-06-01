function mkdirRecursive(thisPath)

if thisPath(end) ~= filesep
    thisPath = [thisPath(:)' filesep];
end
if exist(thisPath)~=7

    seps = find(thisPath==filesep);

    for nsep = 2:numel(seps)
        dirName = thisPath(1:seps(nsep));
        if ~isdir( dirName )
            disp([' creating dir ' dirName]);
            mkdir( dirName );
        end
    end
else
    disp('Directory exists')
end