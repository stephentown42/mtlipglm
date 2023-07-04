function [file, idx, pid] = findFile(files, searchStr, exact)
% main workhorse file for searching for strings    
% [file, idx, pid] = findFile(files, searchStr)
% gets the index for a file in [files] that matches a search string
%
% inputs:
% 	files 
%       [cell array] of strings to compare searchStr to
%           [string] path to directory
% 	searchStr 
%           [string] string to compare <files> to
%       [cell-array] of strings to compare
%   exact  [boolean] flag for wheter searchStr has to match exactly
%
% outputs:
%   file 
%       [cell-array] of strings that gives the file names that match
%                    searchStr. If searchStr is a cell-array, file will
%                    return the files that match all of the searchStr
%                    values
%   idx
%           [double] vector of indices into files
%   pid     
%       [cell-array] of the char index for files
%
% Example:
%   [file_, idx, pid] = findFile({'a.json','a.mat'}, '.json', false);
%   file_   {'a.json'}
%   idx     1
%   pid     {[2],[]}
%
% 2015 jly merged Jake and Leor's findFile versions

% Default settings
if ~exist('exact', 'var'), exact = false; end
if nargin < 2 || isempty(searchStr), searchStr = '.mat'; end

% If input is directory, list files within 
if ~iscell(files) && isfolder(files)
    files = dir(files);
    files = {files(:).name};
    files = files(:);
end

% enforce search str to be a cell array
if ischar(searchStr)
    searchStr = {searchStr};
end

% for loop is faster than cellfun
nFiles = numel(files);
nStr = numel(searchStr);
pid = cell(nFiles,nStr);

if exact
    for kFile = 1 : nFiles
        for kStr = 1:nStr
            tmp = strcmp(files{kFile}, searchStr{kStr});
            tmp(tmp==0)=[];
            pid{kFile, kStr} = tmp;
        end
    end
else
    for kFile = 1 : nFiles
        for kStr = 1:nStr
            pid{kFile,kStr} = strfind(files{kFile}, searchStr{kStr});
        end
    end
end

idx  = find(all(~cellfun(@isempty, pid),2));
file = files(idx);