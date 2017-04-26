function name = getUsername()

%%this is cross-platform:
if isunix()
    name = getenv('USER');
else
    name = getenv('username');
end


%% this only works in unix...
% [~,username]=system('echo $USER');
% %  remove trailing whitespace
%username = strcat(username);
