function rVarUpdate(varargin)% function rVarUpdate(varargin)%% calls update method for list of variable%% if index is empty, use all objects%% Arguments:%   varargin ... either cell array%                   {'<class>' <inds>; ...%                     <class>' <inds>; ...%               - OR -%               list of classes%                   <class1>, <class 2> ...% Copyright 2004 by Joshua I. Gold%   University of Pennsylvaniaglobal ROOT_STRUCTif nargin == 1 && iscell(varargin{1})          % input is of the form:    %   upadte({'class1', [inds]; 'class2', [inds]; ...})    for ii = 1:size(varargin{1})                if isempty(varargin{1}{ii, 2})                        ROOT_STRUCT.(varargin{1}{ii, 1}) = update( ...                ROOT_STRUCT.(varargin{1}{ii, 2}));                    else                        ROOT_STRUCT.(varargin{1}{ii, 1})(varargin{1}{ii, 2}) = update( ...                ROOT_STRUCT.(varargin{1}{ii, 2})(varargin{1}{ii, 2}));                    end            end    else        % input is of the form:    %   update('class1', 'class2', 'class3', ...)    for ii = 1:nargin                    ROOT_STRUCT.(varargin{ii}) = update( ...                ROOT_STRUCT.(varargin{ii}));    endend