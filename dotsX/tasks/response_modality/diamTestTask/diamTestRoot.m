% Build a root struct with a dXparadigm and the diameter test task
global ROOT_STRUCT

% who!
subject = 'MN';

tL = {'taskDiamTest', 1};

% init and set dXparadigm.screenMode to same
sMode = 'remote';
rInit(sMode);

% dXparadigm/runTasks will bomb if dir doesn't exist.
FIRADir = ['/Users/lab/GoldLab/Data/response_modality/diamTest/', subject];
if exist(FIRADir) ~=7
    mkdir(FIRADir)
end

feedbackSelect = { ...
    'showPctGood',      false; ...
    'showNumGood',      false; ...
    'showGoodRate',     false; ...
    'showPctCorrect',   false; ...
    'showNumCorrect',   false; ...
    'showCorrectRate',  false; ...
    'showTrialCount',   false; ...
    'showMoreFeedback', true};
feedbackSelect = cell2struct(feedbackSelect(:,2), feedbackSelect(:,1), 1);

pName = [subject, '_DiamTest'];
rAdd('dXparadigm',      1, ...
    'name',                 pName, ...
    'screenMode',           sMode, ...
    'taskList',             tL, ...
    'taskOrder',            'randomTaskByBlock', ...
    'iti',                  1.0, ...
    'saveToFIRA',           true, ...
    'FIRA_doWrite',         true, ...
    'FIRA_saveDir',         FIRADir, ...
    'FIRA_filenameBase',	subject, ...
    'showFeedback',         true, ...
    'feedbackSelect',       feedbackSelect, ...
    'moreFeedbackFunction', @modalityFeedback);

% load all tasks and save
ROOT_STRUCT.dXparadigm = loadTasks(ROOT_STRUCT.dXparadigm);
bigName = fullfile(rGet('dXparadigm', 1, 'ROOT_saveDir'), pName);
save(bigName, 'ROOT_STRUCT');

% clean up
rDone
clear all