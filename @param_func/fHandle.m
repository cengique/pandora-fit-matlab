function f_handle = fHandle(a_ps, s)

% fHandle - Returns a handle to function with current set of parameters embedded.
%
% Usage:
%   f_handle = fHandle(a_ps, s)
%
% Parameters:
%   a_ps: A param_func object.
%   s: solver_int object (optional).
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
% See also: param_func, function_handle
%
% $Id: fHandle.m 88 2010-04-08 17:41:24Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/04/13

% Copyright (c) 2009-2010 Cengiz Gunay <cengique@users.sf.net>.
% This work is licensed under the Academic Free License ("AFL")
% v. 3.0. To view a copy of this license, please look at the COPYING
% file distributed with this software or visit
% http://opensource.org/licenses/afl-3.0.php.

props = get(a_ps, 'props');

% calculate function and parameters
func = get(a_ps, 'func');
params = getParamsStruct(a_ps);

if isfield(props, 'fHandle')
  % function returns function handle
  f_handle = props.fHandle(params, s);
  if ischar(f_handle)
    % if a string, evaluate in this scope. We do this so that
    % parallel workers can "transparently" see this function
    f_handle = eval(f_handle);
  end
  f_handle = @(x) feval(f_handle, params, x); %f_handle
else
  % return as new handle
  f_handle = @(x) func(params, x);
end
