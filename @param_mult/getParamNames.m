function param_names = getParamNames(a_ps)

% getParamNames - Gets the parameter names of function.
%
% Usage:
%   param_names = getParamNames(a_ps)
%
% Parameters:
%   a_ps: A param_func object.
%		
% Returns:
%   param_names: Cell of parameter names.
%
% Description:
%
% Example:
%   >> param_names = getParamNames(a_ps)
%
% See also: param_func
%
% $Id: func.m 1174 2009-03-31 03:14:21Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2009/12/09

% Copyright (c) 2009 Cengiz Gunay <cengique@users.sf.net>.
% This work is licensed under the Academic Free License ("AFL")
% v. 3.0. To view a copy of this license, please look at the COPYING
% file distributed with this software or visit
% http://opensource.org/licenses/afl-3.0.php.

param_names = getParamNames(a_ps.param_func);
fs_cell = struct2cell(a_ps.f)';
fs_names = fieldnames(a_ps.f);
for f_num = 1:length(fs_cell)
  a_f = fs_cell{f_num};
  f_name = fs_names{f_num};
  pn = cellfun(@(p_name) [ f_name '_' p_name ], getParamNames(a_f), ...
               'UniformOutput', false);
  param_names = [ param_names, pn{:} ];
end