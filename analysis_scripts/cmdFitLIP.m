% Fit GLM to LIP units
% This code calls the fitting code and analysis code for each LIP unit in
% the dataset. The fits are regularized using ridge-regression. This code
% uses a fixed ridge parameter (set below)
% All analyses are handled by the mtlipglm class. The design/fitting of
% each GLM is handled by the glmspike class, which is an instance of the
% neuroGLM class available at https://github.com/jcbyts/neuroGLM
dataPath = getpref('mtlipglm', 'dataPath');

% --- Find experiments that have multiple LIP units
experiments=getExperimentList();
regenerateModelComparisonFiles = true; % regenerate model comparison files from fits
ridgeParameter = 1; % regularize fits with ridge-regression (L2 penatly)
refitModel     = false; % if true, fits will be overwritten

% Parfor if possible, change to for-loop if you do not have the parallel
% toolbox
parfor kExperiment=1:numel(experiments)
    
    % --- setup analysis for each session
    exname=experiments{kExperiment};
    mstruct=mtlipglm(exname, dataPath, 'overwrite', refitModel, 'nFolds', 5);
    mstruct.overwrite =refitModel;
	mstruct.binSize = 10; % Don't change. Analysis code assumes binSize=10
    mstruct.modelDir = fullfile(dataPath,'main_fits');
    % buildTrialStruct builds a struct array of each trial's data in the
    % format that is used by neuroGLM. This is very slow when the MTsim
    % flag is turned on because it has to simulate from the MT model on
    % each trial
	mstruct.buildTrialStruct('IncludeContrast', true, 'MotionEpoch', true, 'MTsim', true);
    
    for k=1:numel(mstruct.trial)
        mstruct.trial(k).gaborContrast=mstruct.trial(k).contrasts;
    end
    
    % loop over neurons and fit LIP neurons only
    for kNeuron=1:numel(mstruct.neurons)
        if mstruct.neurons(kNeuron).isMT % skip MT neurons
            continue
        end
        
        % filename for saved analyses
        fname=fullfile(mstruct.modelDir, [mstruct.neurons(kNeuron).getName 'modelComparison.mat']);
        
        if exist(fname, 'file')&&~mstruct.overwrite&&~regenerateModelComparisonFiles
            fprintf('\n\n\nSkipping [%s] \n\n\n\n\n', fname)
            continue
        else
            % --- Fitting happens here
            % Specify which models to fit:
            % 1 - Stimulus-to-LIP
            % 2 - Stimulus-to-LIP w/ history filter
            % 3 - Inter-Area Coupling
            % 4 - Intra-Area Coupling
            % 5 - MT-to-LIP (simulated MT)
            % 6 - MT-to-LIP (with full choice term)
            modelsToFit = [1 5 6]; % 1, 5, 6 are the only fits provided
            
            % edit mtlipglm/fitAllModels to see fitting code
            g = fitAllModels(mstruct, kNeuron, true, modelsToFit, 'instantaneousCoupling', true, 'rho', ridgeParameter);
            P = mstruct.modelComparison(g);
            parsave(fname, P,'-v7')
        end
        
    end
end
