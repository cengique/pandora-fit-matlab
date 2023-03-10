function ps = ...
      param_func(var_names, param_init_vals, param_names, func_handle, ...
                 id, props)
  
% param_func - A parameterized function, y = f(p, x), with variable, x.
%
% Usage:
%   ps = param_func(var_names, param_init_vals, param_names, func_handle, id, props)
%
% Parameters:
%   var_names: Cell array of names for input and output variables, resp.
%   param_init_vals: Initial values of function parameters or struct of
%     names and initial values.
%   param_names: Cell array of parameter names (empty array if
%   		param_init_vals is a struct).
%   func_handle: Function name or handle that takes params and variable
%   		to produce output.
%   id: An identifying string for this function.
%   props: A structure with any optional properties.
%     xMin, xMax: Minimal and maximal values for input variable, x.
%     paramRanges: 2xn matrix of min (row 1) and max values of each parameter.
%		If a non-NaN range is specified for a parameter
%		its parameters automatically become a ratio between [0,1]
%		that point inside this range (also see 'direct' below).
%     rangeFunc: Function that translates range ratios into parameter
%     		values. Options are 'satlin' for saturated linear and
%     		'logsig' for logistic sigmoid (default='satlin'). 
%     direct: If 1, keep parameters as raw values. If 0, they are
%     		normalized to represent the given range (default=1). 
%     selectParams: Cell of limited param names to be varied and can be
%     		accessed by g/setParams, with the onlySelect
%     		prop. All addressing methods in tests_db/tests2cols can be
%     		used, including regular expressions.
%     isIntable: If 1, this function can be integrated and will be added
%     		to a integrator solver_int when requested by initSolver.
%     fHandle: Handle to function which returns a string that
%     		evaluates to a function. If used, speeds up
%     		integration.
%     name: Name of integrated variable used in solver_int if
%     		isIntable is set. If multiple variables are
%     		returned by function, a cell array of matching
%     		number of names must be provided.
%     VmName: Name of main membrane voltage signal in the
%     		integrator (Also see setVmName).
%     parfor: If 1, uses parallel execution during solver_int/integrate
%     label: Short label string used for plots and exporting.
%     trans2XPP: Use this function to translate the parameters into the
%               XPP format (e.g., '@(a_fs) getParams(a_fs)'. 
%		
% Returns a structure object with the following fields:
%	var_names, func, tests_db.
%
% Description:  
%   Base class for a minimal set of parameters that stand for a single
% function of a single variable, y = f(p, x), where p is a structure that
% holds the function parameters. This is intended for describing
% functions like m_inf and tau_inf curves that are dependent on the
% voltage variable, x. Uses tests_db to store parameter name and values.
%   If props.direct = 0 and paramRanges are given, saves parameters as value
% between [0, 1] that correspond to the range given. This helps bounding the
% parameter values during optimization when the optimizer does not allow
% bounding parameters.
%
% General operations on param_func objects:
%   param_func		- Construct a new param_func object.
%   func		- Evaluate function at value x.
%   plot_make		- Returns a plot_abstract object.
%   plot		- Plots function in new figure.
%   getParams, setParams - Parameter get/set.
%
% Additional methods:
%	See methods('param_func')
%
% Example:
%   f_INaP = ...
%      param_func(...
%        {'voltage [mV]', 'current [nA]'}, ...
%        [-40 -4.5, 1], ...
%        {'V_half', 'k', 'gmax'}, ...
%        @(p,x) ((p.gmax ./ (1 + exp((x(1, :) - p.V_half) ./ p.k))) ...
%                       .* (x - ENa)), ...
%        'steady-state I_{NaP}(V_{step})', ...
%        struct('xMin', -90, 'xMax', 30));
%
% See also: param_act, tests_db, plot_abstract, tests_db/tests2cols
%
% $Id$
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2009/05/28

% TODO: 
% - make this independent of tests_db! use a struct to hold param values

  if nargin == 0 % Called with no params
    ps = struct;
    ps.var_names = {};
    ps.func = @(x) 0;
    ps = class(ps, 'param_func', ...
               tests_db([], {}, {}, ''));
  elseif isa(var_names, 'param_func') % copy constructor?
    ps = var_names;
  else
    if ~ exist('props', 'var')
      props = struct;
    end
    
    % defaults
    props = mergeStructs(props, struct('direct', 1));

    if ~isfield(props, 'rangeFunc')
      props.rangeFunc = @ldsatlins;
    end

    if isstruct(param_init_vals)
      param_names = fieldnames(param_init_vals);
      param_init_vals = cell2mat(struct2cell(param_init_vals));
    end

    % row vector only
    param_init_vals = param_init_vals(:)';

    % use range-scaled values if specified
    if ~ isfield(props, 'direct') || props.direct == 0
      param_init_vals = convertParams2Ratios(param_init_vals, props);
    end
    
    ps = struct;
    ps.var_names = var_names;
    ps.func = func_handle;
    ps = class(ps, 'param_func', ...
               tests_db(param_init_vals, ...
                        param_names, {}, id, props));
  end

