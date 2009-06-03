function a_ps = param_tau_v(param_init_vals, id, props)
  
% param_tau_v - Parameterized time constant function, y = a + b/(1+exp((x+c)/d)).
%
% Usage:
%   a_ps = param_tau_v(param_init_vals, id, props)
%
% Parameters:
%   param_init_vals: Initial values of function parameters, p = [a b c d].
%   id: An identifying string for this function.
%   props: A structure with any optional properties.
% 	   (Rest passed to param_func)
%		
% Returns a structure object with the following fields:
%	param_func.
%
% Description:
%   Specialized version (subclass) of param_func for time constant
%   voltage-dependence curves.
%
% Additional methods:
%	See methods('param_tau_v')
%
% See also: param_func, param_act, param_act_t, tests_db, plot_abstract
%
% $Id: param_tau_v.m 1174 2009-03-31 03:14:21Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2009/06/02

  var_names = {'voltage [mV]', 'time constant [ms]'};
  param_names = {'a', 'b', 'V_half', 'k'};
  func_handle = @(p,x) deal(p(1) + p(2)./(1 + exp((x+p(3)) ./ p(4))), NaN);

  if ~ exist('props', 'var')
    props = struct;
  end

  props = mergeStructs(props, struct('xMin', -100, 'xMax', 100));

  if nargin == 0 % Called with no params
    a_ps = struct;
    a_ps = class(a_ps, 'param_tau_v', ...
                 param_func(var_names, [], param_names, func_handle, '', props));
  elseif isa(param_init_vals, 'param_tau_v') % copy constructor?
    a_ps = param_init_vals;
  else
    a_ps = struct;
    a_ps = class(a_ps, 'param_tau_v', ...
                 param_func(var_names, param_init_vals, param_names, ...
                           func_handle, id, props));
  end
