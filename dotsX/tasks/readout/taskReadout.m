function index_ = taskReadout(varargin)
%Lings's task for testing readout of motion
%
%   index_ = taskReadout(varargin)
%
%   eye tracker for fixation
%   lpHID choices
%
%   varargin{1} should be an array of directions for training or testing
%   varargin{2} should be the motion direction Gaussian standard deviation
%   varargin{3} should be the total number of trial in the session
%
%   index_ specifies the new instance in ROOT_STRUCT.dXtask

% copyright 2008 Benjamin Sommer Heasly University of Pennsylvania

% name for this task
name = mfilename;

% parameters for this session
if nargin >= 3
    dirs = varargin{1};
    dirInc = varargin{2};
    dirStd = varargin{3};
    probeDir = varargin{4};
    numTrials = varargin{5};
    viewingTime = varargin{6};
    varargin(1:6) = [];
else
    dirs = 90;
    dirInc = 20;
    dirStd = 40;
    probeDir = nan; %nan means don't use the probe dots
    numTrials = 700;
    viewingTime = 100;
    warning(sprintf('%s using default parameters', mfilename))
end

% check to see whether we need to show the probe dots
showProbe = ~isnan(probeDir);

% given this number of dirs, how many blocks do we need to get numTrials?
blockReps = ceil(numTrials/(length(dirs)*length(dirStd)*length(probeDir)*2));

arg_dXtc = { ...
    'name',     {'dot_dir_condition', 'plus_minus', 'dot_dir_std', 'probe_dir'}, ...
    'values',	{dirs, [+1 -1], dirStd, probeDir}, ...
    'ptr',      {{},{},{},{'dXdots', 2, 'direction'}}};

arg_dXlr = { ...
    'ptr',      {{'dXdots', 1, 'direction'}}};

% {'group', reuse, set now, set always}
static = {'current', true, true, false};
reswap = {'current', false, true, false};

feedbackSelect = { ...
    'showPctGood',      false; ...
    'showNumGood',      false; ...
    'showGoodRate',     false; ...
    'showPctCorrect',   true; ...
    'showNumCorrect',   false; ...
    'showCorrectRate',  false; ...
    'showTrialCount',   false; ...
    'showMoreFeedback', false};
feedbackSelect = cell2struct(feedbackSelect(:,2), feedbackSelect(:,1), 1);

index_ = rAdd('dXtask', 1, {'root', false, true, false}, ...
    'name',	name(5:end), ...
    'blockReps', blockReps, ...
    'bgColor', [0,0,0], ...
    'helpers', ...
    { ...
    'dXtc',                 4,  reswap, arg_dXtc; ...
    'dXlr',                 1,  static, arg_dXlr; ...
    'gXreadout_hardware',	1,  true,   {}; ...
    'gXreadout_graphics',	1,  true,	{}; ...
    'gXreadout_statelist',	1,  false,	{dirInc, showProbe, viewingTime}; ...
    }, ...
    'statesToFIRA', ...
    { ...
    'indicate', 3; ...
    'acquire',  1; ...
    'hold',     1; ...
    'settle',   1; ...
    'tone1',    1; ...
    'tone2',    1; ...
    'showStim', 3; ...
    'hideStim', 3; ...
    'respond',  1; ...
    'left',     1; ...
    'right',    1; ...
    'correct',  1; ...
    'incorrect',1; ...
    'error',    1; ...
    }, ...
    'objectsToFIRA',    {'saveToFIRA'}, ...
    'anyStates',        {'correct', 'incorrect'}, ...
    'wrtState',         'showStim', ...
    'trialOrder',       'random', ...
    'feedbackSelect',   feedbackSelect, ...
    'showFeedback',     true, ...
    'timeout',          3600, ...
    varargin{:});