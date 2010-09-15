function f_handle = fHandle(a_ps)

% fHandle - Return a handle to function with fixed parameters.
%
% Usage:
%   f_handle = fHandle(a_ps)
%
% Parameters:
%   a_ps: A param_mult object.
%		
% Returns:
%   f_handle: Handle to compiled function that can evaluate f_handle(x).
%
% Description:
%
% Example:
%   >> f_h = fHandle(a_ps)
%   >> a = f_h(x)
%
% See also: param_mult, function_handle
%
% $Id: fHandle.m 88 2010-04-08 17:41:24Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/04/13

% Copyright (c) 2009-2010 Cengiz Gunay <cengique@users.sf.net>.
% This work is licensed under the Academic Free License ("AFL")
% v. 3.0. To view a copy of this license, please look at the COPYING
% file distributed with this software or visit
% http://opensource.org/licenses/afl-3.0.php.

if ~ exist('props', 'var')
  props = struct;
end

% calculate function and parameters
func = get(a_ps, 'func');
params = getParamsStruct(a_ps);
a_struct = struct;

f_names = fieldnames(a_ps.f);
num_funcs = length(f_names);
f_ps = struct2cell(a_ps.f)';
for f_num = 1:num_funcs
  a_f = f_ps{f_num};
  a_struct.(f_names{f_num}) = param_func_compiled(fHandle(a_f), get(a_f, 'id'));
end

% return as new handle
f_handle = @(x) feval(func, a_struct, params, x);