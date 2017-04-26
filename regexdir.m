function Outfiles=regexdir(baseDir,searchExpression)
% OUTFILES = RECURSDIR(BASEDIRECTORY,SEARCHEXPRESSION)
% A recursive search to find files that match the search expression
%

dstr = dir(baseDir);%search current directory and put results in structure
Outfiles = {};
for II = 1:length(dstr)
    if ~dstr(II).isdir && ~isempty(regexp(dstr(II).name,searchExpression,'match')) 
    %look for a match that isn't a directory
        Outfiles{length(Outfiles)+1} = fullfile(baseDir,dstr(II).name);
    end
end
