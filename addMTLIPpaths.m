addpath(fullfile(pwd, 'code'))
addpath(fullfile(pwd, 'code', 'dependencies'))
addpath(fullfile(pwd, 'analysis_scripts'))

filepath = fileparts(which(mfilename));

% this is where your data live
env_settings = loadenv('../Task_Switching/.env');
data_path = fullfile( env_settings('local_home'), 'Task_Switching'); % EDIT THIS LINE %%%%%%%%%%%%%%%%%%

if isempty(data_path)
    error('dataPath must be specified');
end
% set matlab preference so that other functions can access this
setpref('mtlipglm', 'dataPath', data_path)

% set neuroGLM path
neuroGLMpath = fullfile(pwd, '../neuroGLM'); % EDIT THIS LINE %%%%%%%%%%%%%%%%%%
if isempty(neuroGLMpath)
    error('neuroGLM - must be downloaded from https://github.com/jcbyts/neuroGLM');
end
addpath(neuroGLMpath)
if isfolder('neuroGLM')
    error('neuroGLM path invalid');
end

% --- setup directory structure
if isfolder(data_path)
    fit_dir = fullfile(data_path, 'main_fits');
    if ~isfolder(fit_dir)
        mkdir(fit_dir)
    end
    
    fit_dir = fullfile(data_path, 'lip_trunc_fits');
    if ~isfolder(fit_dir)
        mkdir(fit_dir)
    end
end